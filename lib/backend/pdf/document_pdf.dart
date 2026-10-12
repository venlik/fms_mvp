import 'dart:typed_data';

import 'package:finance_management_system/backend/storage/business_logo_x.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/pdf/document_fonts.dart';
import 'package:finance_management_system/backend/pdf/document_formatting.dart';

/// One row in the meta block. Subclasses build a list of these.
class MetaRow {
  final String label;
  final String value;
  final bool bold;

  const MetaRow(this.label, this.value, {this.bold = false});
}

/// Shared skeleton for invoice/receipt PDFs.
///
/// Subclasses supply the pieces that differ:
///   • [documentLabel]  — "INVOICE" / "RECEIPT"
///   • [metaRows]       — the meta block below the parties section
///   • [notesBlock]     — the closing text at the bottom
///
/// Everything else — header, parties, items table, totals row,
/// page footer, fonts, theme, chunking — is shared.
abstract class DocumentPdf {
  const DocumentPdf();

  /// Rows per chunk in the items table. Tune if descriptions wrap
  /// beyond two lines or you change row padding.
  static const int _rowsPerChunk = 16;

  // ── Hooks ───────────────────────────────────────────────────────

  /// Text shown top-right on page 1 and in the PDF metadata title.
  String get documentLabel;

  /// Rows for the meta block, in order.
  List<MetaRow> metaRows(Invoice invoice);

  /// Closing block at the end of the last page.
  pw.Widget notesBlock(Invoice invoice);

  // ── Template ────────────────────────────────────────────────────

  Future<pw.Document> generate({
    required Invoice invoice,
    required LogoStore store,
    required String docNumber,
    DocumentFonts? fonts,
  }) async {
    final theme = _buildTheme(fonts);

    final doc = pw.Document(
      title: '$documentLabel ${invoice.documentNumber}',
      author: invoice.business.name,
      creator: 'finance_management_system',
      theme: theme,
    );

    pw.MemoryImage? logo;
    final logoBytes = await invoice.business.resolveLogoBytes(store);
    if (logoBytes != null && logoBytes.isNotEmpty) {
      logo = pw.MemoryImage(logoBytes);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: theme,
        footer: (ctx) => _pageFooter(ctx, invoice.business.name),
        build: (ctx) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _header(invoice, logo, docNumber),
              pw.SizedBox(height: 18),
              _parties(invoice),
              pw.SizedBox(height: 18),
              _meta(invoice),
              pw.SizedBox(height: 18),
            ],
          ),
          ..._itemsTableChunked(invoice),
          pw.SizedBox(height: 18),
          notesBlock(invoice),
        ],
      ),
    );

    return doc;
  }

  Future<Uint8List> bytes(pw.Document document) async {
    return await document.save();
  }

  // ── Shared widgets ──────────────────────────────────────────────

  pw.Widget _pageFooter(pw.Context context, String businessName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey400, thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                businessName,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _header(
    Invoice invoice,
    pw.MemoryImage? logo,
    String documentNumber,
  ) {
    final b = invoice.business;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 60,
                  height: 40,
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 12),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      b.name,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${b.email}   ${b.phoneNumber}',
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              documentLabel,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "# $documentNumber",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _parties(Invoice invoice) {
    final c = invoice.customer;
    final b = invoice.business;

    pw.Widget billTo() => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Bill To:',
          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(c.name, style: const pw.TextStyle(fontSize: 9.5)),
        if (c.address.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            c.address,
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
        ],
        if (c.phoneNumber.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            c.phoneNumber,
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
        ],
        if (c.email != null && c.email!.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            c.email!,
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
        ],
      ],
    );

    pw.Widget serviceLocation() => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Service Location:',
          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(b.serviceLocation, style: const pw.TextStyle(fontSize: 9.5)),
      ],
    );

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: billTo()),
        pw.SizedBox(width: 16),
        pw.Expanded(child: serviceLocation()),
      ],
    );
  }

  pw.Widget _meta(Invoice invoice) {
    pw.Widget row(MetaRow r) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              r.label,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              r.value,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: r.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [for (final r in metaRows(invoice)) row(r)],
    );
  }

  // ── Items table ─────────────────────────────────────────────────

  List<pw.Widget> _itemsTableChunked(Invoice invoice) {
    final currency = invoice.business.configuredCurrency;

    final items = invoice.items.toList()
      ..sort((a, b) => a.itemId.compareTo(b.itemId));

    if (items.isEmpty) {
      return [pw.Text('No items.', style: const pw.TextStyle(fontSize: 9.5))];
    }

    final headerStyle = pw.TextStyle(
      fontSize: 9.5,
      fontWeight: pw.FontWeight.bold,
    );
    final bodyStyle = const pw.TextStyle(fontSize: 9.5);

    pw.TableRow headerRow() => pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _cell('Item', style: headerStyle),
        _cell('Description', style: headerStyle),
        _cell('Quantity', style: headerStyle),
        _cell('Rate', style: headerStyle),
        _cell('Amount', style: headerStyle, align: pw.TextAlign.right),
      ],
    );

    pw.TableRow totalsRow(double total) => pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        _cell('', style: headerStyle),
        _cell('', style: headerStyle),
        _cell('', style: headerStyle),
        _cell('Total', style: headerStyle, align: pw.TextAlign.right),
        _cell(
          '$currency ${DocFormat.money(total)}',
          style: headerStyle,
          align: pw.TextAlign.right,
        ),
      ],
    );

    final widgets = <pw.Widget>[];
    final total = DocFormat.total(invoice);

    for (var i = 0; i < items.length; i += _rowsPerChunk) {
      final chunk = items.skip(i).take(_rowsPerChunk).toList();
      final isLastChunk = i + _rowsPerChunk >= items.length;

      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(4),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(2.2),
          },
          children: <pw.TableRow>[
            headerRow(),
            for (final item in chunk)
              pw.TableRow(
                children: [
                  _cell(item.name, style: bodyStyle),
                  _cell(item.description, style: bodyStyle),
                  _cell(DocFormat.number(item.quantity), style: bodyStyle),
                  _cell(
                    '$currency ${DocFormat.money(item.priceInCents / 100)}',
                    style: bodyStyle,
                  ),
                  _cell(
                    '$currency ${DocFormat.money(item.priceInCents * item.quantity / 100)}',
                    style: bodyStyle,
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            // Totals row only on the last chunk.
            if (isLastChunk) totalsRow(total),
          ],
        ),
      );

      if (!isLastChunk) {
        widgets.add(pw.SizedBox(height: 12));
      }
    }

    return widgets;
  }

  pw.Widget _cell(
    String text, {
    required pw.TextStyle style,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(text, style: style, textAlign: align),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────

  pw.ThemeData _buildTheme(DocumentFonts? fonts) {
    if (fonts == null || (!fonts.hasPrimary && !fonts.hasAlternate)) {
      return pw.ThemeData.base();
    }

    pw.Font? base;
    pw.Font? bold;
    if (fonts.primaryRegular != null) {
      base = pw.Font.ttf(fonts.primaryRegular!.buffer.asByteData());
    }
    if (fonts.primaryBold != null) {
      bold = pw.Font.ttf(fonts.primaryBold!.buffer.asByteData());
    }
    if (base == null && fonts.alternateRegular != null) {
      base = pw.Font.ttf(fonts.alternateRegular!.buffer.asByteData());
    }
    if (bold == null && fonts.alternateBold != null) {
      bold = pw.Font.ttf(fonts.alternateBold!.buffer.asByteData());
    }

    final fallback = <pw.Font>[];
    if (fonts.alternateRegular != null &&
        fonts.alternateRegular != fonts.primaryRegular) {
      fallback.add(pw.Font.ttf(fonts.alternateRegular!.buffer.asByteData()));
    }
    if (fonts.alternateBold != null &&
        fonts.alternateBold != fonts.primaryBold) {
      fallback.add(pw.Font.ttf(fonts.alternateBold!.buffer.asByteData()));
    }

    return pw.ThemeData.withFont(
      base: base,
      bold: bold,
      fontFallback: fallback.isEmpty ? null : fallback,
    );
  }
}

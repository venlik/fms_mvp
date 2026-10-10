import 'package:pdf/widgets.dart' as pw;

import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/pdf/document_formatting.dart';
import 'package:finance_management_system/backend/pdf/document_pdf.dart';

class InvoicePdf extends DocumentPdf {
  const InvoicePdf();

  @override
  String get documentLabel => 'INVOICE';

  @override
  List<MetaRow> metaRows(Invoice invoice) {
    final currency = invoice.business.configuredCurrency;
    return [
      MetaRow('Date:', DocFormat.date(invoice.date)),
      MetaRow('Payment Terms:', invoice.paymentTerms.label),
      MetaRow('Due Date:', DocFormat.date(invoice.dueDate)),
      MetaRow(
        'Balance Due:',
        '$currency ${DocFormat.money(DocFormat.total(invoice))}',
        bold: true,
      ),
    ];
  }

  @override
  pw.Widget notesBlock(Invoice invoice) {
    final body = (invoice.notes?.isNotEmpty ?? false)
        ? invoice.notes!
        : 'Payment is due by the date shown above. '
            'Please reference the invoice number on all payments.';

    return _sideLabelRow('Terms:', body);
  }
}

/// Local helper, mirrors the "label | body" row used by both subclasses.
pw.Widget _sideLabelRow(String label, String body) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 50,
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.Expanded(
        child: pw.Text(body, style: const pw.TextStyle(fontSize: 9.5)),
      ),
    ],
  );
}
import 'dart:io';
import 'dart:typed_data';

/// Font payloads for PDF generation. Two families:
///   • primary   — the main text font (Latin, currency, punctuation).
///   • alternate — consulted as a fallback when primary lacks a glyph.
///
/// Both optional. If omitted, `pdf`'s built-in Helvetica is used.
class DocumentFonts {
  final Uint8List? primaryRegular;
  final Uint8List? primaryBold;
  final Uint8List? alternateRegular;
  final Uint8List? alternateBold;

  const DocumentFonts({
    this.primaryRegular,
    this.primaryBold,
    this.alternateRegular,
    this.alternateBold,
  });

  /// Convenience: load every face from disk (CLI tools, tests).
  factory DocumentFonts.fromFiles({
    String? primaryRegularPath,
    String? primaryBoldPath,
    String? alternateRegularPath,
    String? alternateBoldPath,
  }) {
    Uint8List? read(String? path) =>
        path == null ? null : File(path).readAsBytesSync();

    return DocumentFonts(
      primaryRegular: read(primaryRegularPath),
      primaryBold: read(primaryBoldPath),
      alternateRegular: read(alternateRegularPath),
      alternateBold: read(alternateBoldPath),
    );
  }

  bool get hasPrimary => primaryRegular != null || primaryBold != null;
  bool get hasAlternate => alternateRegular != null || alternateBold != null;
}
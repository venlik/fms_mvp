import 'package:finance_management_system/backend/models/receipt.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/backend/pdf/document_formatting.dart';
import 'package:finance_management_system/backend/pdf/document_pdf.dart';

class ReceiptPdf extends DocumentPdf {
  final Receipt receipt;
  Payment get _payment => receipt.payment;

  const ReceiptPdf(this.receipt);

  @override
  String get documentLabel => 'RECEIPT';

  @override
  List<MetaRow> metaRows(Invoice invoice) {
    final currency = invoice.business.configuredCurrency;
    return [
      MetaRow('Date:', DocFormat.date(_payment.date)),
      MetaRow('Payment Method:', _payment.method.label),
      if (_payment.reference case final reference? when reference.isNotEmpty)
        MetaRow('Reference:', reference),
      MetaRow('Invoice No:', _payment.invoiceNumber.toString()),
      MetaRow(
        'Amount Paid:',
        '$currency ${DocFormat.money(receipt.payment.amountInCents / 100)}',
        bold: true,
      ),
    ];
  }

  @override
  pw.Widget notesBlock(Invoice invoice) {
    //ignore the provided invoice
    final body = (receipt.payment.notes?.isNotEmpty ?? false)
        ? receipt.payment.notes!
        : 'Great doing business with you.';

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(body, style: const pw.TextStyle(fontSize: 9.5)),
        ),
      ],
    );
  }
}

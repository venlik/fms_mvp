import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';

class Receipt({
  required final DocumentNumber<Receipt> receiptId,
  required final Invoice invoice,
  required final Payment payment,
}) implements Entity {}

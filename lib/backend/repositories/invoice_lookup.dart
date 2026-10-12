import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';

abstract interface class InvoiceLookup {
  Future<Invoice?> findByNumber(DocumentNumber<Invoice> number,{bool includeDeleted = false});
}

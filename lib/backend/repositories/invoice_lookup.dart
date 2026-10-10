import 'package:finance_management_system/backend/models/invoice.dart';

abstract interface class InvoiceLookup {
  Future<Invoice?> findByNumber(int number);
}
import 'package:finance_management_system/backend/details/item_details.dart';

mixin ItemDetailsComparison {
  String get name;
  String get description;

  ItemDetails get details =>
      ItemDetails(name: name, description: description);
}
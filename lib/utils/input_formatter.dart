import 'package:flutter/services.dart';

class WhitelistingInputFormatter extends TextInputFormatter {
  final RegExp _pattern;
  final bool _allowed;

  const WhitelistingInputFormatter(this._pattern, {required this._allowed});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final match = _pattern.hasMatch(newValue.text);

    return match && _allowed ? newValue : oldValue;
  }
}
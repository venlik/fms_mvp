// bin/repl/tokenizer.dart
//
// Splits a command line into tokens, respecting double and single
// quotes. Whitespace outside quotes separates tokens; whitespace
// inside quotes is preserved. No escape sequences — a quote inside a
// quoted string isn't representable, which is fine for a dev tool.
//
//   customer add "Jane Smith" 0712345678 Nairobi
//   → ['customer', 'add', 'Jane Smith', '0712345678', 'Nairobi']

List<String> tokenize(String input) {
  final tokens = <String>[];
  final buf = StringBuffer();
  String? quote; // null when not inside quotes

  for (var i = 0; i < input.length; i++) {
    final ch = input[i];

    if (quote != null) {
      if (ch == quote) {
        quote = null;
      } else {
        buf.write(ch);
      }
      continue;
    }

    if (ch == '"' || ch == "'") {
      quote = ch;
      continue;
    }

    if (ch == ' ' || ch == '\t') {
      if (buf.isNotEmpty) {
        tokens.add(buf.toString());
        buf.clear();
      }
      continue;
    }

    buf.write(ch);
  }

  if (buf.isNotEmpty) tokens.add(buf.toString());
  return tokens;
}
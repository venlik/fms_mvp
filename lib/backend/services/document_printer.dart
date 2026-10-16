abstract interface class DocumentPrinter {
  /// Sends [bytes] to the default printer (or a picker).
  Future<void> print({
    required List<int> bytes,
    required String jobName,
  });
}
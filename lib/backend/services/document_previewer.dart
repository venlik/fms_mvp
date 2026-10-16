abstract interface class DocumentPreviewer {
  /// Shows [bytes] to the user. Returns when the preview is
  /// dismissed (or immediately, for fire-and-forget impls).
  Future<void> preview({
    required List<int> bytes,
    required String title,
  });
}


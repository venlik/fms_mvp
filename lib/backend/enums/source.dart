enum Source {
  file(label: 'file'),
  asset(label: 'asset');

  const Source({required this.label});

  static Source? fromLabel(String label) {
    try {
      return Source.values.firstWhere(
        (v) => label.trim().toLowerCase() == v.label.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  final String label;
}

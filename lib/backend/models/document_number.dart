class DocumentNumber<T>(this.id) {
  final int id;

  @override
  String toString() => id.toString().padLeft(4, '0');

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DocumentNumber<T> && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

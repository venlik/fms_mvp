/// Value equality from a list of props.
///
/// Two [Equatable]s of the same runtime type are equal iff their
/// props lists are equal, element by element.
mixin Equatable {
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Equatable &&
          other.runtimeType == runtimeType &&
          _listEquals(other.props, props));

  @override
  int get hashCode => Object.hashAll(props);

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
import 'package:finance_management_system/backend/enums/source.dart';

class Logo {
  final String path;
  final Source source;

  const Logo({required this.path, required this.source});

  Logo copyWith({String? path, Source? source}) =>
      Logo(path: path ?? this.path, source: source ?? this.source);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Logo && other.path == path && other.source == source);

  @override
  int get hashCode => Object.hash(path, source);

  @override
  String toString() => 'Logo(${source.name}:$path)';
}

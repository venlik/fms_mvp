sealed class DomainError implements Exception {
  const DomainError(this.message);
  final String message;
  @override
  String toString() => '$runtimeType: $message';
}

final class NotFound extends DomainError {
  const NotFound(super.message);
}

final class AlreadyExists extends DomainError {
  const AlreadyExists(super.message);
}

final class InvalidState extends DomainError {
  const InvalidState(super.message);
}

final class StorageFailure extends DomainError {
  const StorageFailure(super.message);
}
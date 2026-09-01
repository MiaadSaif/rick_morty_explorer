/// Base class for all failures in the app.
/// Using `sealed` so the compiler knows all possible subtypes.
/// Each subtype carries a human-readable [message].
sealed class Failure {
  final String message;

  const Failure(this.message);
}

/// No internet connection or network unreachable.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Server returned an error status code (e.g. 500).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error.']);
}

/// Response body could not be parsed as JSON.
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse response.']);
}

/// Local cache read/write error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}

/// Requested item was not found (e.g. 404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'No results found.']);
}

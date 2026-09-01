import 'failures.dart';

/// A sealed class that represents the outcome of an operation.
/// It can only be either [Success] (with a value) or [FailureResult] (with an error).
/// Using `sealed` means the compiler guarantees all cases are handled in switch statements.
sealed class Result<T> {
  const Result();

  /// Returns true if this is a [Success] result.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a [FailureResult].
  bool get isFailure => this is FailureResult<T>;

  /// Returns the value if [Success], otherwise null.
  T? get data => (this as Success<T>?)?.value;

  /// Returns the failure if [FailureResult], otherwise null.
  Failure? get failure => (this as FailureResult<T>?)?.error;
}

/// Represents a successful operation. Holds the returned value.
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

/// Represents a failed operation. Holds the [Failure] describing what went wrong.
final class FailureResult<T> extends Result<T> {
  final Failure error;

  const FailureResult(this.error);
}

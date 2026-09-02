/// Result of an edge function call. Mirrors the `{ ok, data | error }`
/// envelope every function returns.
///
/// Callers pattern-match: `switch (result) { case Success(:final data) ... }`.
sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends ApiResult<T> {
  const Failure(this.code, this.message);
  final String code;
  final String message;
}

import 'package:wordsmith_utils/exceptions/base_exception.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final BaseException exception;

  const Failure(this.exception);
}

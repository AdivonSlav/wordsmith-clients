import 'package:wordsmith_utils/exceptions/exception_types.dart';

class BaseException implements Exception {
  final String message;
  final ExceptionType type;

  BaseException(this.message, {this.type = ExceptionType.genericException});

  @override
  String toString() {
    return message;
  }
}

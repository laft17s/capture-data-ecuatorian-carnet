import 'package:logger/logger.dart';

class MyLogger {
  static final Logger _logger = Logger();

  static void d(String message) => _logger.d(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void wtf(String message) => _logger.w(message);
}

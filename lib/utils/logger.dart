import 'package:logger/logger.dart';

/// Application-wide logging helper backed by the `logger` package.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  static void debug(dynamic message) => _logger.d(message);

  static void info(dynamic message) => _logger.i(message);

  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

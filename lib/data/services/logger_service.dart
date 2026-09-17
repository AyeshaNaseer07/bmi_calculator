import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

typedef AppLogger = LoggerService;

/// - `d` → debug (stripped in release)
/// - `i` → info (lifecycle, navigation)
/// - `w` → warning (deprecations, fallbacks)
/// - `e` → error (caught exceptions → also forward to crash service)
class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  static void d(String msg) => _logger.d(msg);

  static void i(String msg) => _logger.i(msg);

  static void w(String msg) => _logger.w(msg);

  static void e(String msg, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(msg, error: error, stackTrace: stackTrace);
    try {
      FirebaseCrashlytics.instance.recordError(
        error ?? msg,
        stackTrace,
        reason: msg,
        fatal: false,
      );
    } catch (_) {}
  }
}

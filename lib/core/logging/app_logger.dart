import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('[Leyumi][warning] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
  }
}

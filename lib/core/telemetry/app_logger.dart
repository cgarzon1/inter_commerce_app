import 'package:flutter/foundation.dart';

import '../config/app_flavor.dart';
import '../config/environment_config.dart';


class AppLogger {
  AppLogger._();

  static bool get _enabled => EnvironmentConfig.current == AppFlavor.dev;

  /// General-purpose diagnostic line — the `print()` replacement.
  static void log(String message, {String tag = 'App'}) {
    if (!_enabled) return;
    debugPrint('[$tag] $message');
  }

  static void debug(String message, {String tag = 'DEBUG'}) => log(message, tag: tag);

  static void warning(String message, {String tag = 'WARN'}) => log(message, tag: tag);

  static void error(String message, {Object? error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    if (!_enabled) return;
    debugPrint('[$tag] $message${error != null ? ' — $error' : ''}');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  // Event log — placeholder.
  static void event(String name, {Map<String, Object?> parameters = const {}}) {
    log('event="$name" params=$parameters', tag: 'EVENT');
  }
}

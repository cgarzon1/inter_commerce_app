import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_flavor.dart';

/// Resolves configuration values (URLs, keys) for the active [AppFlavor].
class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _flavorDefine = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static final AppFlavor current = AppFlavor.fromString(_flavorDefine);

  static Future<void> init() => dotenv.load(fileName: '.env');

  static String get apiBaseUrl => get('BASE_URL');

  /// Reads [baseKey] for the active flavor first 
  static String get(String baseKey) {
    final flavorKey = '${baseKey}_${current.name.toUpperCase()}';
    final flavorValue = dotenv.env[flavorKey];
    if (flavorValue != null && flavorValue.isNotEmpty) return flavorValue;
    return dotenv.env[baseKey] ?? '';
  }
}

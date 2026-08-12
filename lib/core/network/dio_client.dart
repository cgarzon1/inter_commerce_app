import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/environment_config.dart';
import '../constants/app_constants.dart';

/// Builds the single [Dio] instance used by every remote datasource in the
/// app. There is exactly one of these, created once in the DI container
/// and injected wherever a datasource needs to make an HTTP call — nobody
/// instantiates `Dio()` on their own.
class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}

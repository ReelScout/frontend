import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/interceptor/token_interceptor.dart';
import 'package:frontend/services/token_service.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioConfig {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @singleton
  TokenService tokenService(FlutterSecureStorage secureStorage) =>
      TokenService(secureStorage: secureStorage);

  @singleton
  TokenInterceptor tokenInterceptor(TokenService tokenService) =>
      TokenInterceptor(tokenService: tokenService);

  @singleton
  Dio dio(TokenInterceptor tokenInterceptor) {
    // Load base URL from compile-time define to support flavors/environments
    final baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
        },
        // Treat only 2xx as success so 4xx/5xx throw DioException
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    dio.interceptors.add(tokenInterceptor);

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }
}
/// Centralized Dio configuration (timeouts, interceptors, base options).
///
/// Import this where an HTTP client is needed to ensure consistent
/// networking behavior across the app.

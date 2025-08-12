import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/interceptor/token_interceptor.dart';
import 'package:frontend/services/token_service.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioConfig {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @singleton
  TokenService tokenService(FlutterSecureStorage secureStorage) => TokenService(secureStorage: secureStorage);

  @singleton
  Dio dio(TokenService tokenService) {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));

    // Add interceptors
    dio.interceptors.add(TokenInterceptor(tokenService: tokenService));

    return dio;
  }
}
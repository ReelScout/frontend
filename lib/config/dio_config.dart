import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/interceptor/token_interceptor.dart';
import 'package:frontend/services/token_service.dart';

class DioConfig {
  static DioConfig? _instance;
  late Dio _dio;

  DioConfig._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));

    // Add interceptors
    _dio.interceptors.add(TokenInterceptor(tokenService: TokenService(secureStorage: FlutterSecureStorage())));
  }

  static DioConfig get instance {
    _instance ??= DioConfig._internal();
    return _instance!;
  }

  Dio get dio => _dio;
}
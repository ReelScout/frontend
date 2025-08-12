import 'package:dio/dio.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ServiceModule {
  @singleton
  AuthService authService(Dio dio) => AuthService(dio, baseUrl: "${dio.options.baseUrl}/auth");
}
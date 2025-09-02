import 'package:dio/dio.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/content_service.dart';
import 'package:frontend/services/search_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ServiceModule {
  @singleton
  AuthService authService(Dio dio) => AuthService(dio, baseUrl: "${dio.options.baseUrl}/auth");
  
  @singleton
  UserService userService(Dio dio) => UserService(dio, baseUrl: "${dio.options.baseUrl}/user");
  
  @singleton
  ContentService contentService(Dio dio) => ContentService(dio, baseUrl: "${dio.options.baseUrl}/content");
  
  @singleton
  SearchService searchService(Dio dio) => SearchService(dio, baseUrl: dio.options.baseUrl);
}
import 'dart:io';
import 'package:dio/dio.dart';
import '../services/token_service.dart';

class TokenInterceptor extends Interceptor {
  final TokenService tokenService;

  TokenInterceptor({required this.tokenService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get the stored access token from the secure storage
    final token = await tokenService.getToken();
    
    // Add the token to the request headers if it exists
    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the JWT token is not valid
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      // TODO: Implement
    }

    super.onError(err, handler);
  }
}
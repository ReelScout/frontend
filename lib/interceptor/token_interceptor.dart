import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontend/config/event_bus.dart';
import 'package:frontend/services/token_service.dart';

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
    // Handle authentication errors
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      final path = err.requestOptions.path;
      final isAuthEndpoint =
          path.contains('/auth') || path.endsWith('/login') || path.endsWith('/register');

      // Do not override login/register responses; let UI show backend message
      if (isAuthEndpoint) {
        handler.next(err);
        return;
      }

      await tokenService.removeToken();
      // Dispatch a global logout signal so app state can react
      globalEventBus.emitLogout();
      // Transform error to standardized format
      final standardizedError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: 'Authentication expired. Please login again.',
      );
      handler.next(standardizedError);
      return;
    }

    // Handle forbidden access
    if (err.response?.statusCode == HttpStatus.forbidden) {
      final standardizedError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: 'Access denied',
      );
      handler.next(standardizedError);
      return;
    }

    // Handle connection errors
    if (err.type == DioExceptionType.connectionTimeout) {
      final standardizedError = DioException(
        requestOptions: err.requestOptions,
        type: err.type,
        error: 'Connection timeout',
      );
      handler.next(standardizedError);
      return;
    }

    if (err.type == DioExceptionType.connectionError) {
      final standardizedError = DioException(
        requestOptions: err.requestOptions,
        type: err.type,
        error: 'No internet connection',
      );
      handler.next(standardizedError);
      return;
    }

    // Handle server errors
    if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
      final standardizedError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: 'Server error. Please try again later.',
      );
      handler.next(standardizedError);
      return;
    }

    super.onError(err, handler);
  }
}

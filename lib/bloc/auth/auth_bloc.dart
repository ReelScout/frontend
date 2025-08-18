import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../services/auth_service.dart';
import '../../services/token_service.dart';
import '../../dto/response/custom_response_dto.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthService authService,
    required TokenService tokenService,
  })  : _authService = authService,
        _tokenService = tokenService,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  final AuthService _authService;
  final TokenService _tokenService;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await _authService.login(event.loginRequest);
      
      // Store token if available
      if (response.accessToken.isNotEmpty) {
        await _tokenService.saveToken(response.accessToken);
      }
      
      emit(AuthSuccess(
        token: response.accessToken,
        message: 'Login successful!',
      ));
    } on DioException catch (e) {
      // Use interceptor's standardized error messages for common errors
      String errorMessage = e.error?.toString() ?? 'Login failed';
      
      // Only handle login-specific API error responses
      if (e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          errorMessage = customResponse.message;
        } catch (_) {
          // Use interceptor's standardized error message
          errorMessage = e.error?.toString() ?? 'Login failed';
        }
      }
      
      emit(AuthFailure(error: errorMessage));
    } catch (e) {
      emit(AuthFailure(error: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _tokenService.removeToken();
    emit(AuthLoggedOut());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _tokenService.getToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthSuccess(token: token));
    } else {
      emit(AuthLoggedOut());
    }
  }
}
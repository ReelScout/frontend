import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/token_service.dart';
import 'package:frontend/utils/error_utils.dart';
import 'package:frontend/bloc/auth/auth_event.dart';
import 'package:frontend/bloc/auth/auth_state.dart';

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
    on<RegisterRequested>(_onRegisterRequested);
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
      emit(AuthFailure(error: mapDioError(e)));
    } catch (_) {
      emit(const AuthFailure(error: kGenericErrorMessage));
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

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final response = await _authService.register(event.userRequest);

      // If backend returns a token on sign up, store it
      if (response.accessToken.isNotEmpty) {
        await _tokenService.saveToken(response.accessToken);
      }

      emit(const AuthSuccess(message: 'Registration successful!'));
    } on DioException catch (e) {
      emit(AuthFailure(error: mapDioError(e)));
    } catch (_) {
      emit(const AuthFailure(error: kGenericErrorMessage));
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:frontend/dto/request/user_login_request_dto.dart';
import 'package:frontend/dto/request/user_request_dto.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.loginRequest});

  final UserLoginRequestDto loginRequest;

  @override
  List<Object?> get props => [loginRequest];
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested({required this.userRequest});

  final UserRequestDto userRequest;

  @override
  List<Object?> get props => [userRequest];
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

import 'package:equatable/equatable.dart';
import '../../dto/request/user_login_request_dto.dart';

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

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
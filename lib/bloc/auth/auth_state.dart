import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  const AuthSuccess({this.token, this.message});

  final String? token;
  final String? message;

  @override
  List<Object?> get props => [token, message];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}

class AuthLoggedOut extends AuthState {}
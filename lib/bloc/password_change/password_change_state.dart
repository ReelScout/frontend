import 'package:equatable/equatable.dart';

abstract class PasswordChangeState extends Equatable {
  const PasswordChangeState();

  @override
  List<Object?> get props => [];
}

class PasswordChangeInitial extends PasswordChangeState {}

class PasswordChangeLoading extends PasswordChangeState {}

class PasswordChangeSuccess extends PasswordChangeState {
  const PasswordChangeSuccess({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class PasswordChangeFailure extends PasswordChangeState {
  const PasswordChangeFailure({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}

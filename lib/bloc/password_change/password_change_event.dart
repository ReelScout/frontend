import 'package:equatable/equatable.dart';

abstract class PasswordChangeEvent extends Equatable {
  const PasswordChangeEvent();

  @override
  List<Object?> get props => [];
}

class PasswordChangeSubmitted extends PasswordChangeEvent {
  const PasswordChangeSubmitted({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

class PasswordChangeReset extends PasswordChangeEvent {}

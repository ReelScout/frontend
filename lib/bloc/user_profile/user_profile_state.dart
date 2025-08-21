import 'package:equatable/equatable.dart';
import '../../dto/response/user_response_dto.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  const UserProfileLoaded({required this.user});

  final UserResponseDto user;

  @override
  List<Object?> get props => [user];
}

class UserProfileError extends UserProfileState {
  const UserProfileError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class UserProfileUpdating extends UserProfileState {}

class UserProfileUpdateSuccess extends UserProfileState {
  const UserProfileUpdateSuccess({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
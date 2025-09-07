import 'package:equatable/equatable.dart';
import 'package:frontend/dto/request/user_request_dto.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {}

class ClearUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  const UpdateUserProfile({required this.userRequest});

  final UserRequestDto userRequest;

  @override
  List<Object?> get props => [userRequest];
}

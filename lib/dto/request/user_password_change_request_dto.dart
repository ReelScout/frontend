import 'package:json_annotation/json_annotation.dart';

part '../generated/request/user_password_change_request_dto.g.dart';

@JsonSerializable()
class UserPasswordChangeRequestDto {
  const UserPasswordChangeRequestDto({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  factory UserPasswordChangeRequestDto.fromJson(Map<String, dynamic> json) => _$UserPasswordChangeRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserPasswordChangeRequestDtoToJson(this);

}
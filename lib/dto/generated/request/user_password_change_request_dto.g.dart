// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/user_password_change_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPasswordChangeRequestDto _$UserPasswordChangeRequestDtoFromJson(
  Map<String, dynamic> json,
) => UserPasswordChangeRequestDto(
  currentPassword: json['currentPassword'] as String,
  newPassword: json['newPassword'] as String,
  confirmPassword: json['confirmPassword'] as String,
);

Map<String, dynamic> _$UserPasswordChangeRequestDtoToJson(
  UserPasswordChangeRequestDto instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
  'confirmPassword': instance.confirmPassword,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/user_login_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLoginRequestDto _$UserLoginRequestDtoFromJson(Map<String, dynamic> json) =>
    UserLoginRequestDto(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserLoginRequestDtoToJson(
  UserLoginRequestDto instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
};

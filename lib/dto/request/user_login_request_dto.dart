import 'package:json_annotation/json_annotation.dart';

part '../generated/request/user_login_request_dto.g.dart';

@JsonSerializable()
class UserLoginRequestDto {
  const UserLoginRequestDto({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  factory UserLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginRequestDtoToJson(this);
}
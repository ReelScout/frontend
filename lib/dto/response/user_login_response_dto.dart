import 'package:json_annotation/json_annotation.dart';

part '../generated/response/user_login_response_dto.g.dart';

@JsonSerializable()
class UserLoginResponseDto {
  const UserLoginResponseDto({
    required this.accessToken
  });

  final String accessToken;

  factory UserLoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserLoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginResponseDtoToJson(this);
}
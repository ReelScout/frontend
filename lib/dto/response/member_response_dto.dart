import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/model/role.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/response/member_response_dto.g.dart';

@JsonSerializable()
class MemberResponseDto extends UserResponseDto {
  const MemberResponseDto({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    super.base64Image,
    required this.firstName,
    required this.lastName,
    required this.birthDate
  });

  final String firstName;
  final String lastName;
  final DateTime birthDate;

  factory MemberResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MemberResponseDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MemberResponseDtoToJson(this);
}
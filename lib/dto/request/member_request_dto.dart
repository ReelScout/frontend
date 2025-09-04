import 'package:frontend/dto/request/user_request_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/request/member_request_dto.g.dart';

@JsonSerializable()
class MemberRequestDto extends UserRequestDto {
  const MemberRequestDto({
    required super.username,
    required super.email,
    required super.password,
    super.base64Image,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.favoriteGenres,
  });

  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final List<String>? favoriteGenres;


  factory MemberRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MemberRequestDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MemberRequestDtoToJson(this);
}
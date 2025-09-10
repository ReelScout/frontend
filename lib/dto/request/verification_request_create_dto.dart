import 'package:json_annotation/json_annotation.dart';

part '../generated/request/verification_request_create_dto.g.dart';

@JsonSerializable()
class VerificationRequestCreateDto {
  const VerificationRequestCreateDto({this.message});

  final String? message;

  factory VerificationRequestCreateDto.fromJson(Map<String, dynamic> json) =>
      _$VerificationRequestCreateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationRequestCreateDtoToJson(this);
}


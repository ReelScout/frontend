import 'package:json_annotation/json_annotation.dart';

part '../generated/request/verification_decision_request_dto.g.dart';

@JsonSerializable()
class VerificationDecisionRequestDto {
  const VerificationDecisionRequestDto({this.reason});

  final String? reason;

  factory VerificationDecisionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VerificationDecisionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationDecisionRequestDtoToJson(this);
}


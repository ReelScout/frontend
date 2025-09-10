import 'package:frontend/model/verification_request_status.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/response/verification_request_response_dto.g.dart';

@JsonSerializable()
class VerificationRequestResponseDto {
  const VerificationRequestResponseDto({
    required this.id,
    required this.requesterId,
    required this.requesterUsername,
    required this.status,
    this.message,
    this.decisionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int requesterId;
  final String requesterUsername;
  final VerificationRequestStatus status;
  final String? message;
  final String? decisionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory VerificationRequestResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VerificationRequestResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationRequestResponseDtoToJson(this);
}


import 'package:frontend/model/promotion_request_status.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/response/promotion_request_response_dto.g.dart';

@JsonSerializable()
class PromotionRequestResponseDto {
  const PromotionRequestResponseDto({
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
  final PromotionRequestStatus status;
  final String? message;
  final String? decisionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PromotionRequestResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PromotionRequestResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionRequestResponseDtoToJson(this);
}

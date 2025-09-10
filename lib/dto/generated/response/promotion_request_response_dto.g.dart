// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/promotion_request_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionRequestResponseDto _$PromotionRequestResponseDtoFromJson(
  Map<String, dynamic> json,
) => PromotionRequestResponseDto(
  id: (json['id'] as num).toInt(),
  requesterId: (json['requesterId'] as num).toInt(),
  requesterUsername: json['requesterUsername'] as String,
  status: $enumDecode(_$PromotionRequestStatusEnumMap, json['status']),
  message: json['message'] as String?,
  decisionReason: json['decisionReason'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PromotionRequestResponseDtoToJson(
  PromotionRequestResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'requesterId': instance.requesterId,
  'requesterUsername': instance.requesterUsername,
  'status': _$PromotionRequestStatusEnumMap[instance.status]!,
  'message': instance.message,
  'decisionReason': instance.decisionReason,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$PromotionRequestStatusEnumMap = {
  PromotionRequestStatus.pending: 'PENDING',
  PromotionRequestStatus.approved: 'APPROVED',
  PromotionRequestStatus.rejected: 'REJECTED',
};

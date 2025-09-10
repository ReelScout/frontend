// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/verification_request_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationRequestResponseDto _$VerificationRequestResponseDtoFromJson(
        Map<String, dynamic> json) =>
    VerificationRequestResponseDto(
      id: (json['id'] as num).toInt(),
      requesterId: (json['requesterId'] as num).toInt(),
      requesterUsername: json['requesterUsername'] as String,
      status: $enumDecode(_$VerificationRequestStatusEnumMap, json['status']),
      message: json['message'] as String?,
      decisionReason: json['decisionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VerificationRequestResponseDtoToJson(
        VerificationRequestResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'requesterUsername': instance.requesterUsername,
      'status': _$VerificationRequestStatusEnumMap[instance.status]!,
      'message': instance.message,
      'decisionReason': instance.decisionReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$VerificationRequestStatusEnumMap = {
  VerificationRequestStatus.pending: 'PENDING',
  VerificationRequestStatus.approved: 'APPROVED',
  VerificationRequestStatus.rejected: 'REJECTED',
};


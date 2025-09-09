// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/friendship_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendshipResponseDto _$FriendshipResponseDtoFromJson(
  Map<String, dynamic> json,
) => FriendshipResponseDto(
  id: (json['id'] as num).toInt(),
  status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FriendshipResponseDtoToJson(
  FriendshipResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$FriendshipStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'PENDING',
  FriendshipStatus.accepted: 'ACCEPTED',
  FriendshipStatus.rejected: 'REJECTED',
};

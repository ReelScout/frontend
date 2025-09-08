// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/friendship_with_users_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendshipWithUsersResponseDto _$FriendshipWithUsersResponseDtoFromJson(
  Map<String, dynamic> json,
) => FriendshipWithUsersResponseDto(
  id: (json['id'] as num).toInt(),
  status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  requester: UserResponseDto.fromJson(
    json['requester'] as Map<String, dynamic>,
  ),
  addressee: UserResponseDto.fromJson(
    json['addressee'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$FriendshipWithUsersResponseDtoToJson(
  FriendshipWithUsersResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$FriendshipStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'requester': instance.requester,
  'addressee': instance.addressee,
};

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'PENDING',
  FriendshipStatus.accepted: 'ACCEPTED',
  FriendshipStatus.rejected: 'REJECTED',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/forum_post_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumPostResponseDto _$ForumPostResponseDtoFromJson(
  Map<String, dynamic> json,
) => ForumPostResponseDto(
  id: (json['id'] as num).toInt(),
  threadId: (json['threadId'] as num).toInt(),
  authorUsername: json['authorUsername'] as String,
  body: json['body'] as String,
  parentId: (json['parentId'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ForumPostResponseDtoToJson(
  ForumPostResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'threadId': instance.threadId,
  'authorUsername': instance.authorUsername,
  'body': instance.body,
  'parentId': instance.parentId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

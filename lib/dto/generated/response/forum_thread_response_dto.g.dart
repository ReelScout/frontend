// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/forum_thread_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumThreadResponseDto _$ForumThreadResponseDtoFromJson(
  Map<String, dynamic> json,
) => ForumThreadResponseDto(
  id: (json['id'] as num).toInt(),
  contentId: (json['contentId'] as num).toInt(),
  title: json['title'] as String,
  createdByUsername: json['createdByUsername'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  postCount: (json['postCount'] as num).toInt(),
);

Map<String, dynamic> _$ForumThreadResponseDtoToJson(
  ForumThreadResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'contentId': instance.contentId,
  'title': instance.title,
  'createdByUsername': instance.createdByUsername,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'postCount': instance.postCount,
};

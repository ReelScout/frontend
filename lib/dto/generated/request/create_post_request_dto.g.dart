// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/create_post_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostRequestDto _$CreatePostRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreatePostRequestDto(
  body: json['body'] as String,
  parentId: (json['parentId'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreatePostRequestDtoToJson(
  CreatePostRequestDto instance,
) => <String, dynamic>{'body': instance.body, 'parentId': instance.parentId};

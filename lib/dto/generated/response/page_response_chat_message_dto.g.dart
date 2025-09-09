// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/page_response_chat_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseChatMessageDto _$PageResponseChatMessageDtoFromJson(
  Map<String, dynamic> json,
) => PageResponseChatMessageDto(
  content: (json['content'] as List<dynamic>)
      .map((e) => ChatMessageResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  number: (json['number'] as num).toInt(),
  first: json['first'] as bool,
  last: json['last'] as bool,
  empty: json['empty'] as bool,
);

Map<String, dynamic> _$PageResponseChatMessageDtoToJson(
  PageResponseChatMessageDto instance,
) => <String, dynamic>{
  'content': instance.content,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'size': instance.size,
  'number': instance.number,
  'first': instance.first,
  'last': instance.last,
  'empty': instance.empty,
};

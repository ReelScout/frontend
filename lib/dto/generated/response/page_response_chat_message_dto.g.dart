// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/page_response_chat_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseChatMessageDto _$PageResponseChatMessageDtoFromJson(
  Map<String, dynamic> json,
) => PageResponseChatMessageDto(
  content:
      (json['content'] as List<dynamic>?)
          ?.map(
            (e) => ChatMessageResponseDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num?)?.toInt() ?? 0,
  number: (json['number'] as num?)?.toInt() ?? 0,
  first: json['first'] as bool? ?? false,
  last: json['last'] as bool? ?? false,
  empty: json['empty'] as bool? ?? false,
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

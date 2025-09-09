// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/conversation_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationResponseDto _$ConversationResponseDtoFromJson(
  Map<String, dynamic> json,
) => ConversationResponseDto(
  roomId: json['roomId'] as String,
  type: json['type'] as String,
  counterpartUsername: json['counterpartUsername'] as String,
  lastMessageSender: json['lastMessageSender'] as String,
  lastMessageContent: json['lastMessageContent'] as String,
  lastMessageTimestamp: DateTime.parse(json['lastMessageTimestamp'] as String),
);

Map<String, dynamic> _$ConversationResponseDtoToJson(
  ConversationResponseDto instance,
) => <String, dynamic>{
  'roomId': instance.roomId,
  'type': instance.type,
  'counterpartUsername': instance.counterpartUsername,
  'lastMessageSender': instance.lastMessageSender,
  'lastMessageContent': instance.lastMessageContent,
  'lastMessageTimestamp': instance.lastMessageTimestamp.toIso8601String(),
};

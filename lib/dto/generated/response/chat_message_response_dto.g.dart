// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/chat_message_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageResponseDto _$ChatMessageResponseDtoFromJson(
  Map<String, dynamic> json,
) => ChatMessageResponseDto(
  roomId: json['roomId'] as String,
  sender: json['sender'] as String,
  recipient: json['recipient'] as String?,
  content: json['content'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$ChatMessageResponseDtoToJson(
  ChatMessageResponseDto instance,
) => <String, dynamic>{
  'roomId': instance.roomId,
  'sender': instance.sender,
  'recipient': instance.recipient,
  'content': instance.content,
  'timestamp': instance.timestamp.toIso8601String(),
};

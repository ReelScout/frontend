import 'package:json_annotation/json_annotation.dart';

part '../generated/response/chat_message_response_dto.g.dart';

@JsonSerializable()
class ChatMessageResponseDto {
  ChatMessageResponseDto({
    required this.roomId,
    required this.sender,
    this.recipient,
    required this.content,
    required this.timestamp,
  });

  final String roomId;
  final String sender;
  final String? recipient; // null for room messages
  final String content;
  final DateTime timestamp;

  factory ChatMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageResponseDtoToJson(this);
}


import 'package:json_annotation/json_annotation.dart';

part '../generated/response/chat_message_response_dto.g.dart';

@JsonSerializable()
class ChatMessageResponseDto {
  ChatMessageResponseDto({
    this.conversationId,
    required this.sender,
    this.recipient,
    required this.content,
    required this.timestamp,
  });

  final String? conversationId; // e.g., dm:<a>-<b> (optional from backend)
  final String sender;
  final String? recipient; // Direct messages: recipient is the peer username
  final String content;
  final DateTime timestamp;

  factory ChatMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageResponseDtoToJson(this);
}

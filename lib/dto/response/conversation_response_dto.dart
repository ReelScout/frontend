import 'package:json_annotation/json_annotation.dart';

part '../generated/response/conversation_response_dto.g.dart';

@JsonSerializable()
class ConversationResponseDto {
  ConversationResponseDto({
    required this.roomId,
    required this.type,
    required this.counterpartUsername,
    required this.lastMessageSender,
    required this.lastMessageContent,
    required this.lastMessageTimestamp,
  });

  final String roomId;
  final String type;
  final String counterpartUsername;
  final String lastMessageSender;
  final String lastMessageContent;
  final DateTime lastMessageTimestamp;

  factory ConversationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseDtoToJson(this);
}


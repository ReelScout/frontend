import 'package:json_annotation/json_annotation.dart';

import 'package:frontend/dto/response/chat_message_response_dto.dart';

part '../generated/response/page_response_chat_message_dto.g.dart';

@JsonSerializable()
class PageResponseChatMessageDto {
  PageResponseChatMessageDto({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.empty,
  });

  final List<ChatMessageResponseDto> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final bool empty;

  factory PageResponseChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$PageResponseChatMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PageResponseChatMessageDtoToJson(this);
}


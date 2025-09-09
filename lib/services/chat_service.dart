import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:frontend/dto/response/conversation_response_dto.dart';
import 'package:frontend/dto/response/page_response_chat_message_dto.dart';

part 'generated/chat_service.g.dart';

@RestApi()
abstract class ChatService {
  factory ChatService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _ChatService;

  // Direct messages history with a user
  @GET('/dm/{username}')
  Future<PageResponseChatMessageDto> getDirectHistory(
    @Path('username') String username,
    @Query('page') int page,
    @Query('size') int size,
  );

  // Recent direct conversations
  @GET('/conversations')
  Future<List<ConversationResponseDto>> getRecentConversations(
    @Query('size') int size,
  );
}

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:frontend/dto/response/page_response_chat_message_dto.dart';

part 'generated/chat_service.g.dart';

@RestApi()
abstract class ChatService {
  factory ChatService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _ChatService;

  // Group room history
  @GET('/room/{roomId}')
  Future<PageResponseChatMessageDto> getRoomHistory(
    @Path('roomId') String roomId,
    @Query('page') int page,
    @Query('size') int size,
  );

  // Direct messages history with a user
  @GET('/dm/{username}')
  Future<PageResponseChatMessageDto> getDirectHistory(
    @Path('username') String username,
    @Query('page') int page,
    @Query('size') int size,
  );

  // Resolve stable DM room id for a user pair
  @GET('/dm/{username}/room')
  Future<String> getDirectRoomId(@Path('username') String username);
}


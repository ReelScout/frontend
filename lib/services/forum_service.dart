import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import 'package:frontend/dto/request/create_thread_request_dto.dart';
import 'package:frontend/dto/request/create_post_request_dto.dart';
import 'package:frontend/dto/response/forum_thread_response_dto.dart';
import 'package:frontend/dto/response/forum_post_response_dto.dart';

part 'generated/forum_service.g.dart';

@RestApi()
abstract class ForumService {
  factory ForumService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _ForumService;

  @GET('/{contentId}/threads')
  Future<List<ForumThreadResponseDto>> getThreadsByContent(@Path('contentId') int contentId);

  @POST('/{contentId}/threads')
  Future<ForumThreadResponseDto> createThread(
    @Path('contentId') int contentId,
    @Body() CreateThreadRequestDto dto,
  );

  @GET('/threads/{threadId}/posts')
  Future<List<ForumPostResponseDto>> getPostsByThread(@Path('threadId') int threadId);

  @POST('/threads/{threadId}/posts')
  Future<ForumPostResponseDto> createPost(
    @Path('threadId') int threadId,
    @Body() CreatePostRequestDto dto,
  );
}


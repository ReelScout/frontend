import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../dto/request/content_request_dto.dart';
import '../dto/response/content_response_dto.dart';

part 'generated/content_service.g.dart';

@RestApi()
abstract class ContentService {
  factory ContentService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _ContentService;

  @POST('/content/add')
  Future<ContentResponseDto> addContent(@Body() ContentRequestDto contentRequestDto);

  // TODO: Update

  @GET('/all')
  Future<List<ContentResponseDto>> getAllContent();

  @GET('/content-types')
  Future<List<String>> getContentTypes();
}
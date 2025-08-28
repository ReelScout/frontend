import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../dto/request/content_request_dto.dart';
import '../dto/response/content_response_dto.dart';
import '../dto/response/custom_response_dto.dart';

part 'generated/content_service.g.dart';

@RestApi()
abstract class ContentService {
  factory ContentService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _ContentService;

  @POST('/add')
  Future<ContentResponseDto> addContent(@Body() ContentRequestDto contentRequestDto);

  @GET('/all')
  Future<List<ContentResponseDto>> getAllContent();

  @GET('/content-types')
  Future<List<String>> getContentTypes();

  @GET('/my-contents')
  Future<List<ContentResponseDto>> getMyContents();

  @PUT('/update/{id}')
  Future<ContentResponseDto> updateContent(@Path('id') int id, @Body() ContentRequestDto contentRequestDto);

  @DELETE('/delete/{id}')
  Future<CustomResponseDto> deleteContent(@Path('id') int id);
}
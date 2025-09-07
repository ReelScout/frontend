import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:frontend/dto/response/search_response_dto.dart';

part 'generated/search_service.g.dart';

@RestApi()
abstract class SearchService {
  factory SearchService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _SearchService;

  @GET('/search')
  Future<SearchResponseDto> search(@Query('query') String query);
}

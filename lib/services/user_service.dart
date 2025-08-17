import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/response/user_response_dto.dart';

part 'generated/user_service.g.dart';

@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _UserService;

  @GET("/me")
  Future<UserResponseDto> getCurrentUser();
}
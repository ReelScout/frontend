import 'package:dio/dio.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/response/user_response_dto.dart';
import '../dto/request/user_password_change_request_dto.dart';

part 'generated/user_service.g.dart';

@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _UserService;

  @GET('/me')
  Future<UserResponseDto> getCurrentUser();

  @PATCH('/change-password')
  Future<CustomResponseDto> changePassword(@Body() UserPasswordChangeRequestDto userPasswordChangeRequestDto);
}
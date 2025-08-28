import 'package:dio/dio.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:frontend/dto/response/user_login_response_dto.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/request/user_request_dto.dart';
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

  @PUT('/update')
  Future<UserLoginResponseDto?> update(@Body() UserRequestDto userRequestDto);

  @DELETE('/delete/{id}')
  Future<CustomResponseDto> delete(@Path('id') int id);
}
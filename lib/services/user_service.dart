import 'package:dio/dio.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:frontend/dto/response/user_login_response_dto.dart';
import 'package:retrofit/retrofit.dart';

import 'package:frontend/dto/request/user_password_change_request_dto.dart';
import 'package:frontend/dto/request/user_request_dto.dart';
import 'package:frontend/dto/response/user_response_dto.dart';

part 'generated/user_service.g.dart';

@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _UserService;

  @GET('/all')
  Future<List<UserResponseDto>> getAll();

  @GET('/id/{id}')
  Future<UserResponseDto> getById(@Path('id') int id);

  @GET('/me')
  Future<UserResponseDto> getCurrentUser();

  @PATCH('/change-password')
  Future<CustomResponseDto> changePassword(@Body() UserPasswordChangeRequestDto userPasswordChangeRequestDto);

  @PUT('/update')
  Future<UserLoginResponseDto?> update(@Body() UserRequestDto userRequestDto);
}

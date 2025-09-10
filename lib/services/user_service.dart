import 'package:dio/dio.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:frontend/dto/response/user_login_response_dto.dart';
import 'package:retrofit/retrofit.dart';

import 'package:frontend/dto/request/user_password_change_request_dto.dart';
import 'package:frontend/dto/request/user_request_dto.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/dto/request/suspend_user_request_dto.dart';
import 'package:frontend/dto/request/ban_user_request_dto.dart';

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

  @POST('/id/{id}/suspend')
  Future<CustomResponseDto> suspendUser(
    @Path('id') int id,
    @Body() SuspendUserRequestDto dto,
  );

  @DELETE('/id/{id}/suspend')
  Future<CustomResponseDto> unsuspendUser(
    @Path('id') int id,
  );

  // Admin-only endpoints
  @POST('/id/{id}/ban')
  Future<CustomResponseDto> permanentlyBan(
    @Path('id') int id,
    @Body() BanUserRequestDto? dto,
  );

  // Note: backend accepts optional body, but we omit it here
  @DELETE('/id/{id}/ban')
  Future<CustomResponseDto> unban(
    @Path('id') int id,
  );

  // List users reported by moderators (admin only)
  @GET('/reported/moderator')
  Future<List<UserResponseDto>> listUsersReportedByModerators();
}

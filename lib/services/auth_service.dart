import 'package:frontend/dto/response/user_login_response_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../dto/request/user_login_request_dto.dart';
import '../dto/request/user_request_dto.dart';

part 'generated/auth_service.g.dart';

@RestApi()
abstract class AuthService {
  factory AuthService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _AuthService;

  @POST('/login')
  Future<UserLoginResponseDto> login(@Body() UserLoginRequestDto request);

  @POST('/register')
  Future<UserLoginResponseDto> register(@Body() UserRequestDto userRequestDto);
}
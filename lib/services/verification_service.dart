import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:frontend/dto/request/verification_request_create_dto.dart';
import 'package:frontend/dto/request/verification_decision_request_dto.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:frontend/dto/response/verification_request_response_dto.dart';

part 'generated/verification_service.g.dart';

@RestApi()
abstract class VerificationService {
  factory VerificationService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _VerificationService;

  // Member: request verification (optional message)
  @POST('/request')
  Future<CustomResponseDto> requestVerification(@Body() VerificationRequestCreateDto dto);

  // Moderator: list pending requests
  @GET('/requests/pending')
  Future<List<VerificationRequestResponseDto>> listPendingRequests();

  // Moderator: approve request
  @PATCH('/requests/{id}/approve')
  Future<CustomResponseDto> approve(@Path('id') int id);

  // Moderator: reject request with optional reason
  @PATCH('/requests/{id}/reject')
  Future<CustomResponseDto> reject(
    @Path('id') int id,
    @Body() VerificationDecisionRequestDto dto,
  );

  // Any authenticated user: list own requests
  @GET('/requests/me')
  Future<List<VerificationRequestResponseDto>> myRequests();
}


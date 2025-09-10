import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:frontend/dto/request/promotion_request_create_dto.dart';
import 'package:frontend/dto/request/promotion_decision_request_dto.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:frontend/dto/response/promotion_request_response_dto.dart';

part 'generated/promotion_service.g.dart';

@RestApi()
abstract class PromotionService {
  factory PromotionService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _PromotionService;

  // Member -> Verified
  @POST('/verified/request')
  Future<CustomResponseDto> requestVerifiedPromotion(@Body() PromotionRequestCreateDto dto);

  @GET('/verified/requests/pending')
  Future<List<PromotionRequestResponseDto>> listPendingVerifiedRequests();

  @PATCH('/verified/requests/{id}/approve')
  Future<CustomResponseDto> approveVerified(@Path('id') int id);

  @PATCH('/verified/requests/{id}/reject')
  Future<CustomResponseDto> rejectVerified(
    @Path('id') int id,
    @Body() PromotionDecisionRequestDto dto,
  );

  // Verified -> Moderator
  @POST('/moderator/request')
  Future<CustomResponseDto> requestModeratorPromotion(@Body() PromotionRequestCreateDto dto);

  @GET('/moderator/requests/pending')
  Future<List<PromotionRequestResponseDto>> listPendingModeratorRequests();

  @PATCH('/moderator/requests/{id}/approve')
  Future<CustomResponseDto> approveModerator(@Path('id') int id);

  @PATCH('/moderator/requests/{id}/reject')
  Future<CustomResponseDto> rejectModerator(
    @Path('id') int id,
    @Body() PromotionDecisionRequestDto dto,
  );

  // Common
  @GET('/requests/me')
  Future<List<PromotionRequestResponseDto>> myRequests();
}

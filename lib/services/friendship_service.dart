import 'package:dio/dio.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:frontend/dto/response/friendship_with_users_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/friendship_service.g.dart';

@RestApi()
abstract class FriendshipService {
  factory FriendshipService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _FriendshipService;

  // POST /request/{memberId}
  @POST('/request/{memberId}')
  Future<CustomResponseDto> sendFriendRequest(@Path() int memberId);

  // PATCH /accept/{memberId}
  @PATCH('/accept/{memberId}')
  Future<CustomResponseDto> acceptFriendRequest(@Path() int memberId);

  // PATCH /reject/{memberId}
  @PATCH('/reject/{memberId}')
  Future<CustomResponseDto> rejectFriendRequest(@Path() int memberId);

  // DELETE /remove/{memberId}
  @DELETE('/remove/{memberId}')
  Future<CustomResponseDto> removeFriend(@Path() int memberId);

  // GET /
  @GET('')
  Future<List<FriendshipWithUsersResponseDto>> getFriends();

  // GET /requests/incoming
  @GET('/requests/incoming')
  Future<List<FriendshipWithUsersResponseDto>> getIncomingRequests();

  // GET /requests/outgoing
  @GET('/requests/outgoing')
  Future<List<FriendshipWithUsersResponseDto>> getOutgoingRequests();
}

import 'package:frontend/dto/response/custom_response_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../dto/request/watchlist_request_dto.dart';
import '../dto/response/watchlist_response_dto.dart';

part 'generated/watchlist_service.g.dart';

@RestApi()
abstract class WatchlistService {
  factory WatchlistService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _WatchlistService;
  
  @GET('/my-watchlists')
  Future<List<WatchlistResponseDto>> getMyWatchlists();

  @POST('/add')
  Future<WatchlistResponseDto> addWatchlist(@Body() WatchlistRequestDto watchlist);

  @PUT('/update/{id}')
  Future<WatchlistResponseDto> updateWatchlist(@Path() int id, @Body() WatchlistRequestDto watchlist);

  @DELETE('/delete/{id}')
  Future<CustomResponseDto> deleteWatchlist(@Path() int id);

  @PATCH('/{watchlistId}/add-content/{contentId}')
  Future<CustomResponseDto> addContentToWatchlist(@Path() int watchlistId, @Path() int contentId);

  @PATCH('/{watchlistId}/remove-content/{contentId}')
  Future<CustomResponseDto> removeContentFromWatchlist(@Path() int watchlistId, @Path() int contentId);

  @GET('/by-content/{contentId}')
  Future<List<WatchlistResponseDto>> getWatchlistsByContentId(@Path() int contentId);
}
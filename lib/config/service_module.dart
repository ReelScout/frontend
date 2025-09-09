import 'package:dio/dio.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/content_service.dart';
import 'package:frontend/services/search_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/services/watchlist_service.dart';
import 'package:frontend/services/forum_service.dart';
import 'package:frontend/services/friendship_service.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/services/chat_realtime_service.dart';
import 'package:injectable/injectable.dart';
import 'package:frontend/services/token_service.dart';

@module
abstract class ServiceModule {
  @singleton
  AuthService authService(Dio dio) => AuthService(dio, baseUrl: "${dio.options.baseUrl}/auth");
  
  @singleton
  UserService userService(Dio dio) => UserService(dio, baseUrl: "${dio.options.baseUrl}/user");
  
  @singleton
  ContentService contentService(Dio dio) => ContentService(dio, baseUrl: "${dio.options.baseUrl}/content");
  
  @singleton
  SearchService searchService(Dio dio) => SearchService(dio, baseUrl: "${dio.options.baseUrl}/search");

  @singleton
  WatchlistService watchlistService(Dio dio) => WatchlistService(dio, baseUrl: "${dio.options.baseUrl}/user/watchlist");

  @singleton
  ForumService forumService(Dio dio) => ForumService(dio, baseUrl: "${dio.options.baseUrl}/content/forum");

  @singleton
  FriendshipService friendshipService(Dio dio) => FriendshipService(dio, baseUrl: "${dio.options.baseUrl}/user/friends");

  @singleton
  ChatService chatService(Dio dio) => ChatService(dio, baseUrl: "${dio.options.baseUrl}/chat");

  // Realtime chat service needs API origin to derive WS endpoint
  @singleton
  ChatRealtimeService chatRealtimeService(TokenService tokenService, Dio dio) =>
      ChatRealtimeService(tokenService: tokenService, apiBaseUrl: dio.options.baseUrl);
}

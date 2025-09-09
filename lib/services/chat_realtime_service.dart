import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:frontend/dto/response/chat_message_response_dto.dart';
import 'package:frontend/services/token_service.dart';
// Registered via ServiceModule; no class-level injectable annotation needed.
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatRealtimeService {
  ChatRealtimeService({
    required this.tokenService,
    required this.apiBaseUrl,
  });

  final TokenService tokenService;
  // Example: http://localhost:8080/api/v1
  final String apiBaseUrl;

  StompClient? _client;
  StreamController<ChatMessageResponseDto>? _dmController;
  bool _dmSubscribed = false;
  bool _wantDm = false;

  bool get isConnected => _client?.connected == true;

  // Derive origin (scheme + authority) from API base URL
  String get _httpUrl {
    final uri = Uri.parse(apiBaseUrl);
    final origin = '${uri.scheme}://${uri.authority}';
    return '$origin/ws';
  }

  String get _wsUrl {
    final http = Uri.parse(_httpUrl);
    final scheme = (http.scheme == 'https') ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      userInfo: http.userInfo,
      host: http.host,
      port: http.hasPort ? http.port : null,
      path: http.path,
      query: http.query,
      fragment: http.fragment,
    ).toString();
  }

  Future<void> connect({void Function()? onConnected, void Function(Object error)? onError}) async {
    if (isConnected) {
      onConnected?.call();
      return;
    }

    final token = await tokenService.getToken();
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

    final config = kIsWeb
        ? StompConfig.sockJS(
            url: _httpUrl,
            stompConnectHeaders: headers,
            webSocketConnectHeaders: headers,
            onConnect: (StompFrame frame) {
              _resubscribeAll();
              onConnected?.call();
            },
            onWebSocketError: (dynamic err) => onError?.call(err),
            onStompError: (StompFrame frame) => onError?.call(Exception('STOMP error: ${frame.body}')),
            onDisconnect: (frame) {
              _dmSubscribed = false;
            },
            reconnectDelay: const Duration(milliseconds: 4000),
          )
        : StompConfig(
            url: _wsUrl,
            stompConnectHeaders: headers,
            webSocketConnectHeaders: headers,
            onConnect: (StompFrame frame) {
              _resubscribeAll();
              onConnected?.call();
            },
            onWebSocketError: (dynamic err) => onError?.call(err),
            onStompError: (StompFrame frame) => onError?.call(Exception('STOMP error: ${frame.body}')),
            onDisconnect: (frame) {
              _dmSubscribed = false;
            },
            reconnectDelay: const Duration(milliseconds: 4000),
          );

    _client = StompClient(config: config);

    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    _dmSubscribed = false;
    // Do not close controllers to allow reconnection; callers can manage lifecycle
  }

  // Subscribe to personal direct-message queue
  Stream<ChatMessageResponseDto> subscribeDirect() {
    _dmController ??= StreamController.broadcast();
    final controller = _dmController!;
    _wantDm = true;

    if (isConnected && !_dmSubscribed) {
      _client!.subscribe(
        destination: '/user/queue/dm',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            final data = jsonDecode(frame.body!);
            controller.add(ChatMessageResponseDto.fromJson(Map<String, dynamic>.from(data)));
          }
        },
      );
      _dmSubscribed = true;
    }

    return controller.stream;
  }

  // Send message to group room
  void sendToRoom(String roomId, String content) {
    if (!isConnected) return;
    _client!.send(destination: '/app/chat/$roomId', body: jsonEncode({'content': content}));
  }

  // Send direct message to a username
  void sendDirect(String username, String content) {
    if (!isConnected) return;
    _client!.send(destination: '/app/dm/$username', body: jsonEncode({'content': content}));
  }

  void _resubscribeAll() {
    if (_wantDm && !_dmSubscribed) {
      // Subscribe to personal queue
      if (_dmController == null) {
        _dmController = StreamController.broadcast();
      }
      _client!.subscribe(
        destination: '/user/queue/dm',
        callback: (StompFrame frame) {
          if (frame.body != null && _dmController != null) {
            final data = jsonDecode(frame.body!);
            _dmController!.add(ChatMessageResponseDto.fromJson(Map<String, dynamic>.from(data)));
          }
        },
      );
      _dmSubscribed = true;
    }

    // no-op for rooms (feature removed)
  }
}

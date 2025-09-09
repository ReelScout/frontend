import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/services/token_service.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

/// Core STOMP/WebSocket client responsible for:
/// - Managing a single shared connection
/// - Handling auth headers
/// - Re-subscribing generic destinations on reconnect
/// - Exposing generic subscribe/send helpers
class RealtimeCore {
  RealtimeCore({
    required this.tokenService,
    required this.apiBaseUrl,
  });

  final TokenService tokenService;
  final String apiBaseUrl; // e.g., http://localhost:8080/api/v1

  StompClient? _client;
  final List<_RawSub> _rawSubs = <_RawSub>[];

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
            onDisconnect: (frame) {},
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
            onDisconnect: (frame) {},
            reconnectDelay: const Duration(milliseconds: 4000),
          );

    _client = StompClient(config: config);
    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  // Subscribe to a destination and receive raw JSON map messages.
  Stream<Map<String, dynamic>> subscribeRaw(String destination) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    void cb(StompFrame frame) {
      if (frame.body != null && !controller.isClosed) {
        final data = jsonDecode(frame.body!);
        controller.add(Map<String, dynamic>.from(data));
      }
    }
    _rawSubs.add(_RawSub(destination, cb));
    if (isConnected) {
      _client!.subscribe(destination: destination, callback: cb);
    }
    return controller.stream;
  }

  // Generic send helper, body can be a Map or String
  void send(String destination, Object body) {
    if (!isConnected) return;
    final payload = body is String ? body : jsonEncode(body);
    _client!.send(destination: destination, body: payload);
  }

  void _resubscribeAll() {
    for (final s in _rawSubs) {
      _client!.subscribe(destination: s.destination, callback: s.callback);
    }
  }
}

class _RawSub {
  final String destination;
  final void Function(StompFrame frame) callback;
  _RawSub(this.destination, this.callback);
}


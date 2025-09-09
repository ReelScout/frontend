import 'dart:async';

import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/websocket/realtime_core.dart';

class ContentRealtimeService {
  ContentRealtimeService(this._core);

  final RealtimeCore _core;

  Future<void> connect({void Function()? onConnected, void Function(Object error)? onError}) async {
    return _core.connect(onConnected: onConnected, onError: onError);
  }

  void disconnect() => _core.disconnect();

  // Broadcast of newly created content (backend: /queue/content/new)
  Stream<ContentResponseDto> subscribeNewContent() {
    return _core
        .subscribeRaw('/queue/content/new')
        .map((json) => ContentResponseDto.fromJson(json));
  }
}

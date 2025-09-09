import 'dart:async';
import 'package:frontend/dto/response/chat_message_response_dto.dart';
import 'package:frontend/websocket/realtime_core.dart';

class ChatRealtimeService {
  ChatRealtimeService(this._core);

  final RealtimeCore _core;
  StreamController<ChatMessageResponseDto>? _dmController;
  bool _dmSubscribed = false;

  bool get isConnected => _core.isConnected;

  Future<void> connect({void Function()? onConnected, void Function(Object error)? onError}) async {
    return _core.connect(onConnected: onConnected, onError: onError);
  }

  void disconnect() {
    _core.disconnect();
    _dmSubscribed = false;
  }

  // Subscribe to personal direct-message queue
  Stream<ChatMessageResponseDto> subscribeDirect() {
    _dmController ??= StreamController.broadcast();
    final controller = _dmController!;

    if (_core.isConnected && !_dmSubscribed) {
      _core.subscribeRaw('/user/queue/dm').listen((json) {
        controller.add(ChatMessageResponseDto.fromJson(json));
      });
      _dmSubscribed = true;
    }

    return controller.stream;
  }

  // Send direct message to a username
  void sendDirect(String username, String content) {
    if (!_core.isConnected) return;
    _core.send('/app/dm', {'recipient': username, 'content': content});
  }
}

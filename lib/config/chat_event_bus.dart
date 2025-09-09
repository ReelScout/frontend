import 'dart:async';

import 'package:frontend/dto/response/chat_message_response_dto.dart';
import 'package:frontend/services/chat_realtime_service.dart';

class ChatEventBus {
  final StreamController<ChatMessageResponseDto> _messageController =
      StreamController<ChatMessageResponseDto>.broadcast();

  Stream<ChatMessageResponseDto> get onMessage => _messageController.stream;

  StreamSubscription<ChatMessageResponseDto>? _dmSub;

  Future<void> attach(ChatRealtimeService realtime) async {
    await realtime.connect();
    _dmSub ??= realtime.subscribeDirect().listen((event) {
      if (!_messageController.isClosed) {
        _messageController.add(event);
      }
    });
  }

  void detach() {
    _dmSub?.cancel();
    _dmSub = null;
  }

  void dispose() {
    detach();
    _messageController.close();
  }
}

final ChatEventBus chatEventBus = ChatEventBus();


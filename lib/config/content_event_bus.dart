import 'dart:async';

import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/websocket/content_realtime_service.dart';

class ContentEventBus {
  final StreamController<ContentResponseDto> _newContentController =
      StreamController<ContentResponseDto>.broadcast();

  Stream<ContentResponseDto> get onNewContent => _newContentController.stream;

  StreamSubscription<ContentResponseDto>? _contentSub;

  Future<void> attach(ContentRealtimeService realtime) async {
    await realtime.connect();
    _contentSub ??= realtime.subscribeNewContent().listen((event) {
      if (!_newContentController.isClosed) {
        _newContentController.add(event);
      }
    });
  }

  void detach() {
    _contentSub?.cancel();
    _contentSub = null;
  }

  void dispose() {
    detach();
    _newContentController.close();
  }
}

final ContentEventBus contentEventBus = ContentEventBus();

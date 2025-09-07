import 'dart:async';

/// Simple global event bus for cross-cutting signals (e.g., auth logout).
class GlobalEventBus {
  GlobalEventBus();

  final StreamController<void> _logoutController = StreamController<void>.broadcast();

  Stream<void> get onLogout => _logoutController.stream;

  void emitLogout() {
    if (!_logoutController.isClosed) {
      _logoutController.add(null);
    }
  }

  void dispose() {
    _logoutController.close();
  }
}

// Shared singleton instance
final GlobalEventBus globalEventBus = GlobalEventBus();


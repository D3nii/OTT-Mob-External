import 'dart:async';

class AsyncMutex {
  Completer<void>? _completer;

  Future<void> lock() async {
    while (_completer != null) {
      await _completer!.future;
    }
    _completer = Completer<void>();
  }

  void unlock() {
    final completer = _completer;
    if (completer != null) {
      _completer = null;
      completer.complete();
    }
  }
}

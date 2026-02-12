import 'dart:async';

import 'package:flutter/material.dart';

class LoadedImageHandler extends ChangeNotifier {
  late StreamController<bool> _streamController;

  Stream<bool> get loaded => _streamController.stream;

  LoadedImageHandler() {
    _streamController = StreamController<bool>();
  }

  void loadFinish(int delay) {
    _streamController.add(true);
  }
}

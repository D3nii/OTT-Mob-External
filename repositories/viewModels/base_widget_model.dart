import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class BaseWidgetModel {
  bool _showTheWidget = false;
  StreamController<Widget?> _widgetToShow = BehaviorSubject<Widget?>();

  bool get showTheWidget => _showTheWidget;

  Stream<Widget?> get widgetToShow => _widgetToShow.stream;

  void showOverlayWidget(bool showWidget, Widget widgetToShow) {
    _showTheWidget = showWidget;
    _widgetToShow.add(showWidget ? widgetToShow : null);
  }
}

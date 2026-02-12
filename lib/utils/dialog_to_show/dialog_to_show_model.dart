import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';

class DialogToShowModel extends BaseModel {
  bool _showTheWidget = false;
  late Widget _widgetToShow;
  late Widget _parent;

  bool get showTheWidget => _showTheWidget;

  Widget get widgetToShow => _widgetToShow;
  StreamSubscription? streamSubscription;

  Widget get parent => _parent;

  set parent(Widget value) {
    _parent = value;
    notifyListeners();
  }

  set widgetToShow(Widget value) {
    _widgetToShow = value;
    notifyListeners();
  }

  set showTheWidget(bool value) {
    _showTheWidget = value;
    notifyListeners();
  }

  ///First Method to load data
  void init(HomeModel homeModel) {
    streamSubscription?.cancel();
    streamSubscription = homeModel.dialogsStreamController.stream.listen((Widget event) {
      if (event == Container()) {
        homeModel.tabBarVisible = true;
        // DialogToShow(Container(), showWidgetDialog: false,);
        showOverlayWidget(false, event);
        // baseWidgetModel.showOverlayWidget(false, event);

      } else {
        // DialogToShow(event, showWidgetDialog: true,);
        showOverlayWidget(true, event);
        homeModel.tabBarVisible = true;
        // baseWidgetModel.showOverlayWidget(true, event);
      }
    });
  }

  void showOverlayWidget(bool showWidget, Widget widgetToShow) {
    showTheWidget = showWidget;
    this.widgetToShow = widgetToShow;
    notifyListeners();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }
}

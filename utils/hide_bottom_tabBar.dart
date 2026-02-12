import 'dart:async';

import 'package:onetwotrail/repositories/models/home_component_visibility_status.dart';

class HideBottomTabBar {
  HomeComponentVisibilityStatus status = HomeComponentVisibilityStatus(bottomTabBar: true);
  final StreamController<HomeComponentVisibilityStatus> _hideBottomTabBar = StreamController.broadcast();

  Stream<HomeComponentVisibilityStatus> get hideBottomTabBar => _hideBottomTabBar.stream;

  HideBottomTabBar() {
    _hideBottomTabBar.add(status);
  }

  void changeVisibility(bool visible) {
    status.bottomTabBar = visible;
    _hideBottomTabBar.add(HomeComponentVisibilityStatus(bottomTabBar: visible));
  }
}

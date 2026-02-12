import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/ui/views/discover/discover_view.dart';
import 'package:onetwotrail/ui/views/profile/profile_view.dart';
import 'package:onetwotrail/ui/views/search_bar_view.dart';
import 'package:onetwotrail/utils/dialog_to_show/dialog_to_show_model.dart';
import 'package:onetwotrail/utils/hide_bottom_tabBar.dart';
import 'package:rxdart/rxdart.dart';

class HomeModel extends BaseModel {
  final ApplicationApi _applicationApi;
  List<Widget> _tabs = [];
  int _currentTab = 0;
  final StreamController<bool> _tabBarVisible = BehaviorSubject<bool>();
  late HideBottomTabBar _hideBottomTabBar;
  final ScrollController _discoverScrollController = ScrollController();
  final ScrollController _myTrailsScrollController = ScrollController();
  final ScrollController _profileScrollController = ScrollController();
  double _discoverScrollPosition = 0;
  double _myTrailsScrollPosition = 0;
  double _profileScrollPosition = 0;
  late RestartableTimer _scrollTimer;
  final StreamController<Widget> dialogsStreamController = StreamController<Widget>.broadcast();
  Widget? _widgetDialogToShow;
  bool _showWidget = false;
  DialogToShowModel _dialogToShowModel = DialogToShowModel();

  final log = Logger((HomeModel).toString());

  HomeModel(this._applicationApi);

  int get currentTab => _currentTab;

  StreamController<Widget> get streamController => dialogsStreamController;

  Stream<Widget> get dialogsWidget => dialogsStreamController.stream;

  ScrollController get discoverScrollController => _discoverScrollController;

  ScrollController get myTrailsScrollController => _myTrailsScrollController;

  ScrollController get profileScrollController => _profileScrollController;

  Stream<bool> get streamTabBarVisible => _tabBarVisible.stream;

  Widget get widgetDialogToShow => _widgetDialogToShow!;

  bool get showWidget => _showWidget;

  DialogToShowModel get dialogToShowModel => _dialogToShowModel;

  set dialogToShowModel(DialogToShowModel value) {
    _dialogToShowModel = value;
    notifyListeners();
  }

  set showWidget(bool value) {
    _showWidget = value;
    notifyListeners();
  }

  set widgetDialogToShow(Widget value) {
    _widgetDialogToShow = value;
    notifyListeners();
  }

  HideBottomTabBar get hideBottomTabBar => _hideBottomTabBar;

  List<Widget> get tabs => _tabs;

  double get discoverScrollPosition => _discoverScrollPosition;

  set discoverScrollPosition(double value) {
    _discoverScrollPosition = value;
    notifyListeners();
  }

  set tabs(List<Widget> value) {
    _tabs = value;
    notifyListeners();
  }

  set hideBottomTabBar(HideBottomTabBar value) {
    _hideBottomTabBar = value;
    notifyListeners();
  }



  set currentTab(int currentTab) {
    if (currentTab == 0 && _currentTab == 0 && discoverScrollController.positions.isNotEmpty) {
      discoverScrollController.animateTo(0.0, duration: Duration(milliseconds: 750), curve: Curves.easeIn);
    }
    if (currentTab != _currentTab) {
      _currentTab = currentTab;
      notifyListeners();
    }
  }

  set tabBarVisible(bool tabBarVisible) {
    _tabBarVisible.add(tabBarVisible);
  }

  Future<void> initState(BuildContext context) async {
    startApiTokenListener(context);
    await _applicationApi.updateContext();
    discoverScrollController.addListener(_updateDiscoverScrollState);
    myTrailsScrollController.addListener(_updateMyTrailsScrollState);
    profileScrollController.addListener(_updateProfileScrollState);
    tabs = [
      DiscoverView(),
      SearchBarView(),
      ProfileView(),
    ];
    _scrollTimer = RestartableTimer(Duration(seconds: 1), _timerElapsed);
    notifyListeners();
  }

  void startApiTokenListener(BuildContext context) {
    // Listen to token changes and reset tab if token is lost
    _applicationApi.contextStream.stream.listen((apiToken) {
      if (!apiToken.hasToken) {
        currentTab = 0;
      }
    });
  }

  void changeTab(int selectedIndex) {
    currentTab = selectedIndex;
  }

  void _updateDiscoverScrollState() {
    if (discoverScrollController.position.pixels < 0) {
      return;
    }
    if (_discoverScrollPosition < discoverScrollController.position.pixels) {
      _hideTabBar();
    } else if (_discoverScrollPosition > discoverScrollController.position.pixels) {
      _showTabBar();
    }
    _discoverScrollPosition = discoverScrollController.position.pixels;
  }

  void _updateMyTrailsScrollState() {
    if (myTrailsScrollController.position.pixels < 0) {
      return;
    }
    if (_myTrailsScrollPosition < myTrailsScrollController.position.pixels) {
      _hideTabBar();
    } else if (_myTrailsScrollPosition > myTrailsScrollController.position.pixels) {
      _showTabBar();
    }
    _myTrailsScrollPosition = myTrailsScrollController.position.pixels;
  }

  void _updateProfileScrollState() {
    if (profileScrollController.position.pixels < 0) {
      return;
    }
    if (_profileScrollPosition < profileScrollController.position.pixels) {
      _hideTabBar();
    } else if (_profileScrollPosition > profileScrollController.position.pixels) {
      _showTabBar();
    }
    _profileScrollPosition = profileScrollController.position.pixels;
  }

  void _showTabBar() {
    tabBarVisible = true;
    _scrollTimer.cancel();
  }

  void _hideTabBar() {
    tabBarVisible = false;
    _scrollTimer.reset();
  }

  void _timerElapsed() {
    _showTabBar();
    _scrollTimer.cancel();
  }

  void scrollProfileToTop() {
    if (_profileScrollController.hasClients) {
      _profileScrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    dialogsStreamController.close();
    _tabBarVisible.close();
    super.dispose();
  }
}

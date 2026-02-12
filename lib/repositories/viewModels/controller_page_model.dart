import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class ControllerPageModel extends BaseModel {
  PageController _pageController = PageController(
    initialPage: 0,
  );
  late DiscoveryService _discoveryService;

  PageController get pageController => _pageController;
  DiscoveryService get discoveryService => _discoveryService;

  set pageController(PageController value) {
    _pageController = value;
    notifyListeners();
  }

  set discoveryService(DiscoveryService value) {
    _discoveryService = value;
    notifyListeners();
  }
}

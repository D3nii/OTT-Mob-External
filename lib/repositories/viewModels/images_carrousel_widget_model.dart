import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class ImagesCarrouselWidgetModel extends BaseModel {
  late int _initialIndex;
  int _pageCounter = 1;
  PageController _pageController = PageController();

  int get initialIndex => _initialIndex;

  PageController get pageController => _pageController;

  int get pageCounter => _pageCounter;

  set pageCounter(int value) {
    _pageCounter = value;
    notifyListeners();
  }

  set initialIndex(int value) {
    _initialIndex = value;
    notifyListeners();
  }

  ///Next Image
  void nextImage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
    }
  }

  ///Previous Image
  void previousImage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
    }
  }
}

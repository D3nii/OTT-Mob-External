import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/utils/hide_bottom_tabBar.dart';

class ExperiencesSubMenuModel extends BaseModel {
  late Experience _experiences;
  late HideBottomTabBar _hideBottomTabBar;
  late BaseWidgetModel _baseModel;
  late HomeModel _homeModel;

  Experience get experiences => _experiences;

  HideBottomTabBar get hideBottomTabBar => _hideBottomTabBar;

  BaseWidgetModel get baseModel => _baseModel;

  HomeModel get homeModel => _homeModel;

  set homeModel(HomeModel value) {
    _homeModel = value;
    notifyListeners();
  }

  set baseModel(BaseWidgetModel value) {
    _baseModel = value;
    notifyListeners();
  }

  set hideBottomTabBar(HideBottomTabBar value) {
    _hideBottomTabBar = value;
    notifyListeners();
  }

  set experiences(Experience value) {
    _experiences = value;
    notifyListeners();
  }

  ///First method
  init() {
    // _hideBottomTabBar?.changeVisibility(false);
  }
}

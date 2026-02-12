import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class CheckBoxModel extends BaseModel {
  bool _active = false;

  bool get active => _active;

  set active(bool value) {
    _active = value;
    notifyListeners();
  }

  init() {}
}

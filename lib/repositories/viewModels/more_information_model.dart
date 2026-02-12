import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class MoreInformationModel extends BaseModel {
  late Experience _experience;
  late User _user;

  Experience get experience => _experience;
  final List<dynamic> _listOfTags = [];

  List<dynamic> get listOfTags => _listOfTags;

  // Direct access to user with proper notification
  User get user => _user;

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  set experience(Experience value) {
    _experience = value;
    notifyListeners();
  }

  void init() {
    notifyListeners();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class ExperienceActionsModel extends BaseModel {
  late User _user;
  late Experience _experience;
  late ApplicationApi _applicationApi;
  ScrollController _scrollController = ScrollController();
  bool _showBottom = false;
  late TrailService _trailService;

  Experience get experience => _experience;

  ScrollController get scrollController => _scrollController;

  bool get showBottom => _showBottom;

  User get user => _user;

  TrailService get trailService => _trailService;

  set trailService(TrailService value) {
    _trailService = value;
    notifyListeners();
  }

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  set showBottom(bool value) {
    _showBottom = value;
    notifyListeners();
  }

  set scrollController(ScrollController value) {
    _scrollController = value;
    notifyListeners();
  }

  set experience(Experience value) {
    _experience = value;
    notifyListeners();
  }

  set applicationApi(ApplicationApi value) {
    _applicationApi = value;
    notifyListeners();
  }

  init() {}

  Future<ApplicationApiResponse> hideExperience() async {
    setState(ViewState.Busy);
    ApplicationApiResponse result = await _applicationApi.hideExperience(experience.experienceId);
    setState(ViewState.Idle);
    return result;
  }
}

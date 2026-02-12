import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/enums/trail_status.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

import 'controller_page_board_controller_model.dart';

class BoardViewModel extends BaseModel {
  late TrailService _trailService;
  Trail _trail = Trail(
    id: 0,
    name: '',
    description: '',
    listingDescription: '',
    author: '',
    collaborators: [],
    experiences: [],
    latitude: 0,
    longitude: 0,
    status: TrailStatus.PAUSED,
    lockVersion: 0,
    itineraryId: 0,
    itineraryEstimatedTime: Duration.zero
  );
  bool _showLoading = false;
  List<Experience> _listRecentRemoved = [];
  List<Experience> _listBoardExperiences = [];
  String _error = "";
  bool _showError = false;
  late BuildContext _context;
  bool _flag = true;
  bool _suggestedExpanded = true;

  TrailService get trailService => _trailService;

  Trail get trail => _trail;

  late ControllerPageBoardAndItineraryModel _controllerPageBoard;

  ControllerPageBoardAndItineraryModel get controllerPageBoard => _controllerPageBoard;

  List<Experience> get listRecentRemoved => _listRecentRemoved;

  bool get showLoading => _showLoading;

  List<Experience> get listBoardExperiences => _listBoardExperiences;

  String get error => _error;

  BuildContext get context => _context;

  bool get showError => _showError;

  bool get flag => _flag;

  bool get suggestedExpanded => _suggestedExpanded;

  set suggestedExpanded(bool suggestedExpanded) {
    if (suggestedExpanded != _suggestedExpanded) {
      _suggestedExpanded = suggestedExpanded;
      notifyListeners();
    }
  }

  onExpansionChanged(bool expanded) {
    suggestedExpanded = expanded;
  }

  set flag(bool value) {
    _flag = value;
    notifyListeners();
  }

  set showError(bool value) {
    _showError = value;
    notifyListeners();
  }

  set controllerPageBoard(ControllerPageBoardAndItineraryModel value) {
    _controllerPageBoard = value;
    notifyListeners();
  }

  set context(BuildContext value) {
    _context = value;
    notifyListeners();
  }

  set error(String value) {
    _error = value;
    notifyListeners();
  }

  set listBoardExperiences(List<Experience> value) {
    _listBoardExperiences = value;
    notifyListeners();
  }

  set showLoading(bool value) {
    _showLoading = value;
    notifyListeners();
  }

  set listRecentRemoved(List<Experience> value) {
    _listRecentRemoved = value;
    notifyListeners();
  }

  set trail(Trail value) {
    _trail = value;
    notifyListeners();
  }

  set trailService(TrailService value) {
    _trailService = value;
    notifyListeners();
  }

  Trail obtainCurrentTrail() {
    return trail;
  }

  Future<ApplicationApiResponse> checkForTrailAndCreateOne() async {
    return Future.value(ApplicationApiResponse(
      statusCode: 200,
      result: true,
      responseBody: "",
      responseObject: Trail(
        id: 0,
        name: '',
        description: '',
        listingDescription: '',
        author: '',
        collaborators: [],
        experiences: [],
        latitude: 0,
        longitude: 0,
        status: TrailStatus.PAUSED,
        lockVersion: 0,
        itineraryId: 0,
        itineraryEstimatedTime: Duration.zero
      )
    ));
  }
}

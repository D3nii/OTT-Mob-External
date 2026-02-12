import 'dart:async';

import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:rxdart/rxdart.dart';

import 'base_widget_model.dart';

class ExperienceInfoModel extends BaseModel {
  Experience experience = Experience(
    experienceId: 0,
    name: '',
    description: '',
    latitude: 0,
    longitude: 0,
    imageUrls: [],
    experienceInTrailId: 0,
    title: '',
    destinationName: '',
    email: '',
    phone: '',
    website: '',
    facebook: '',
    instagram: '',
    whatsApp: '',
    stayTime: Duration.zero,
    visitStartTime: DateTime.now(),
    visitEndTime: DateTime.now(),
    active: false,
    approved: false,
    draftId: '',
    adultsOnly: false,
    allTerrainVehicleOnly: false,
    birdWatching: false,
    camping: false,
    carbonNeutral: false,
    evCharger: false,
    foodDrinks: false,
    internet: false,
    nearBy: [],
    parking: false,
    paymentMethods: [],
    petFriendly: false,
    publicTransport: false,
    recommendations: '',
    related: [],
    securityLockers: false,
    showers: false,
    smokingArea: false,
    toilets: false,
    topics: [],
    visited: false,
    wheelchairAccessible: false,
    accommodation: false,
    likes: 0
  );
  late ApplicationApi _applicationApi;
  StreamController<List<Experience>> _temp = BehaviorSubject();
  StreamSubscription<List<Experience>>? subscription;
  List<Experience> _listOfExperiences = [];
  List<dynamic> _listOfTags = [];
  bool showError = false;
  User? user;
  late BaseWidgetModel _baseWidgetModel;
  bool _seeMoreClicked = false;

  StreamController<List<Experience>> get temp => _temp;

  List<Experience> get listOfExperiences => _listOfExperiences;

  Stream<List<Experience>> get trailsStream => _temp.stream;

  List<dynamic> get listOfTags => _listOfTags;

  BaseWidgetModel get baseWidgetModel => _baseWidgetModel;

  bool get seeMoreClicked => _seeMoreClicked;

  set seeMoreClicked(bool value) {
    _seeMoreClicked = value;
    notifyListeners();
  }

  set baseWidgetModel(BaseWidgetModel value) {
    _baseWidgetModel = value;
    notifyListeners();
  }

  set listOfTags(List<dynamic> value) {
    _listOfTags = value;
    notifyListeners();
  }

  set listOfExperiences(List<Experience> value) {
    _listOfExperiences = value;
    notifyListeners();
  }

  set temp(StreamController<List<Experience>> value) {
    _temp = value;
    notifyListeners();
  }

  ExperienceInfoModel(this._applicationApi, this.user);

  init(Experience experience) async {
    if (state == ViewState.Busy) {
      return;
    }
    setState(ViewState.Busy);
    Experience? temp = await _applicationApi.getExperience(experience.experienceId);
    showError = false;
    if (temp != null) {
      this.experience = temp;
    }
    setState(ViewState.Idle);
  }

  String getExperienceDescription() {
    return experience.description;
  }
}

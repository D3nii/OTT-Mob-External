import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:rxdart/rxdart.dart';

class GenerateItineraryFromBoardModel extends BaseModel {
  bool _showDialog = false;
  String _error = "";
  int _adultNumber = 1;
  int _teensNumber = 0;
  int _kidsNumber = 0;
  late Trail _trail;
  late TrailService _trailService;
  DateTime _startTimeStamp = DateTime.now();
  DateTime _endTimeStamp = DateTime.now().add(Duration(days: 1));
  StreamController<List<Experience>> _streamController = BehaviorSubject();

  DateTime get endTimeStamp => _endTimeStamp;

  DateTime get startTimeStamp => _startTimeStamp;

  int get adultNumber => _adultNumber;

  int get teensNumber => _teensNumber;

  int get kidsNumber => _kidsNumber;

  StreamController<List<Experience>> get streamController => _streamController;

  bool get showDialog => _showDialog;

  String get error => _error;

  set error(String value) {
    _error = value;
    notifyListeners();
  }

  set showDialog(bool value) {
    _showDialog = value;
    notifyListeners();
  }

  set trail(Trail value) {
    _trail = value;
  }

  set streamController(StreamController<List<Experience>> value) {
    _streamController = value;
    notifyListeners();
  }

  set kidsNumber(int value) {
    _kidsNumber = value;
    notifyListeners();
  }

  set teensNumber(int value) {
    _teensNumber = value;
    notifyListeners();
  }

  set adultNumber(int value) {
    _adultNumber = value;
    notifyListeners();
  }

  set startTimeStamp(DateTime value) {
    _startTimeStamp = value;
    notifyListeners();
  }

  set endTimeStamp(DateTime value) {
    _endTimeStamp = value;
    notifyListeners();
  }

  set trailService(TrailService value) {
    _trailService = value;
  }

  init() async {
    notifyListeners();
  }

  int subtract(int number, {min = 0}) {
    if (number <= min) {
      return min;
    } else {
      return number - 1;
    }
  }

  int plus(int number) {
    return number + 1;
  }

  Future<ApplicationApiResponse<Itinerary>> updateItinerary(BuildContext context) async {
    if (adultNumber <= 0) {
      _error = '${AppLocalizations.of(context)?.selectAtLeastOneAdultText ?? "Select at least one adult"}';
      // Create a dummy Itinerary object for the error case
      Itinerary dummyItinerary = Itinerary(
        id: 0,
        trailId: 0,
        adultParticipantsCount: 0,
        teenParticipantsCount: 0,
        kidsParticipantsCount: 0,
        startDate: DateTime.now().toIso8601String(),
        endDate: DateTime.now().toIso8601String(),
        startingExperienceId: 0,
        endingExperienceId: 0,
        events: []
      );
      return ApplicationApiResponse(result: false, statusCode: 400, responseBody: _error, responseObject: dummyItinerary);
    }
    ApplicationApiResponse response = await _trailService.updateItinerary(
      _trail.itineraryId,
      startTimeStamp,
      adultNumber,
      teensNumber,
      kidsNumber,
    );
    if (response.statusCode >= 400) {
      _error = '${AppLocalizations.of(context)?.somethingWentWrongText ?? "Something went wrong"}';
      // Create a dummy Itinerary object for the error case
      Itinerary dummyItinerary = Itinerary(
        id: 0,
        trailId: 0,
        adultParticipantsCount: 0,
        teenParticipantsCount: 0,
        kidsParticipantsCount: 0,
        startDate: DateTime.now().toIso8601String(),
        endDate: DateTime.now().toIso8601String(),
        startingExperienceId: 0,
        endingExperienceId: 0,
        events: []
      );
      return ApplicationApiResponse(result: false, statusCode: response.statusCode, responseBody: _error, responseObject: dummyItinerary);
    }
    String name = _trail.name;
    _trail.name = name;
    return ApplicationApiResponse<Itinerary>(
      result: response.result,
      statusCode: response.statusCode,
      responseBody: response.responseBody,
      responseObject: response.responseObject as Itinerary
    );
  }

  String getDateForApi(String iso8601string) {
    String date = iso8601string;

    List<String> temp = date.split("T");
    return temp[0];
  }

  bool isValidEndTime(DateTime date) {
    return _startTimeStamp.millisecondsSinceEpoch < date.millisecondsSinceEpoch;
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/visit_itinerary_event.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:onetwotrail/v2/util/mutex.dart';
import 'package:rxdart/rxdart.dart';

class ControllerPageBoardAndItineraryModel extends BaseModel {
  static final _log = Logger('ControllerPageBoardAndItineraryModel');
  AsyncMutex trailLock = AsyncMutex();
  final BuildContext _context;
  Duration _duration = Duration.zero;
  List dayActivities = [];
  List otherDaysActivities = [];
  List<Experience> _listBoardExperiences = [];
  List<Experience> _listBoardRemovedExperiences = [];
  PageController pageController = PageController(initialPage: 0);
  StreamController<List<Experience>> _boardExperiences = BehaviorSubject();
  StreamController<List<Experience>> _recentRemoved = BehaviorSubject();
  String _error = "";
  String uuid = DateTime.now().toString();
  final Trail trail;
  final TrailService _trailService;
  bool _showItineraryMap = false;
  bool _updatingBoard = false;
  bool _updatingItinerary = false;
  StreamSubscription? _itinerarySubscription;
  bool flag = true;
  bool showGenerateItineraryButton = false;
  int _indexListViewTrailItinerary = 0;
  int index = 0;
  int showGenerateItineraryAnimDuration = 0;

  ControllerPageBoardAndItineraryModel(this._context, this._trailService, this.trail);

  List<Experience> get listBoardRemovedExperiences => _listBoardRemovedExperiences;

  List<Experience> get listBoardExperiences => _listBoardExperiences;

  bool get updatingBoard => _updatingBoard;

  bool get updatingItinerary => _updatingItinerary;




  int get indexListViewTrailItinerary => _indexListViewTrailItinerary;

  String get error => _error;

  bool get showItineraryMap => _showItineraryMap;

  Duration get duration => _duration;



  set duration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  set showItineraryMap(bool value) {
    _showItineraryMap = value;
    notifyListeners();
  }

  set error(String value) {
    _error = value;
    notifyListeners();
  }

  set indexListViewTrailItinerary(int value) {
    if (value != _indexListViewTrailItinerary) {
      _indexListViewTrailItinerary = value;
    }
  }

  isTrailNull() {
    // Trail is never null since it's a required constructor parameter
    return false;
  }

  Future<ApplicationApiResponse> deleteCurrentTrail(Trail trail) async {
    ApplicationApiResponse result = await _trailService.deleteTrail(trail);
    return result;
  }

  Stream<List<Experience>> get boardExperiences => _boardExperiences.stream;

  Stream<List<Experience>> get recentRemoved => _recentRemoved.stream;

  loadBoardData(bool useDelay) async {

    if (!mounted) {
      return;
    }

    // Load the itinerary if the trail has one
    if (trail.itineraryId > 0) {
      loadItineraryData();
    }

    if (flag) {
      _recentRemoved.close();
      _recentRemoved = BehaviorSubject();
      duration = trail.itineraryEstimatedTime;
      List<Experience> recentRemoved = [];
      List<Experience> boardExperiences = [];
      trail.experiences.forEach((value) {
        boardExperiences.add(value);
      });
      _boardExperiences.add(boardExperiences);
      _listBoardExperiences = boardExperiences;
      _recentRemoved.add(recentRemoved);
      _listBoardRemovedExperiences = recentRemoved;
      makeBoardFadeInAnim();
      flag = false;
      notifyListeners();
    }
  }

  removeExperienceTrail(baseWidgetModel, Experience experience) async {
    await removeFromTrailExperience(experience);
    applyBoardUpdate();
  }

  addExperienceTrail(baseWidgetModel, Experience experience) async {
    await addToBoardExperiences(experience);
    applyBoardUpdate();
  }

  BuildContext get context => _context;

  removeFromTrailExperience(Experience experience) async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }
    bool isAdded = isExperienceInBoard(experience);
    bool isDeleted = isDeletedExperienceInBoard(experience);
    if (isAdded) {
      _listBoardExperiences.removeWhere((element) => element.experienceId == experience.experienceId);
      _boardExperiences.add(_listBoardExperiences);
    }
    if (!isDeleted) {
      _listBoardRemovedExperiences.add(experience);
      _recentRemoved.add(_listBoardRemovedExperiences);
    }
    _updatingBoard = true;
    notifyListeners();
  }

  addToBoardExperiences(Experience experience) async {
    bool isAdded = isExperienceInBoard(experience);
    bool isDeleted = isDeletedExperienceInBoard(experience);
    if (!isAdded) {
      _listBoardExperiences.add(experience);
      _boardExperiences.add(_listBoardExperiences);
    }
    if (isDeleted) {
      _listBoardRemovedExperiences.removeWhere((element) => element.experienceId == experience.experienceId);
      _recentRemoved.add(_listBoardRemovedExperiences);
    }
    _updatingBoard = true;
    notifyListeners();
  }

  applyBoardUpdate() async {
    // Update the experiences in the trail
    _log.info('Starting applyBoardUpdate');
    _updatingItinerary = true;
    notifyListeners();
    var updatedTrail = await _updateTrailExperiences(_listBoardExperiences);
    _updatingBoard = false;
    _log.info('Updated trail: $updatedTrail');
    if (mounted) {
      if (updatedTrail == null) {
        _updatingItinerary = false;
        notifyListeners();
        Dialogs.showMessageDialog(
            context, AppLocalizations.of(context)!.somethingWentWrongText, () => loadBoardData(false));
      } else {
        trail.experiences = updatedTrail.experiences;
        trail.itineraryEstimatedTime = updatedTrail.itineraryEstimatedTime;
        duration = updatedTrail.itineraryEstimatedTime;

        // Load the itinerary if the trail has one, otherwise turn off the loading state
        loadItineraryData();
      }
    }
  }

  @override
  void dispose() {
    _itinerarySubscription?.cancel();
    super.dispose();
  }

  bool isExperienceInBoard(Experience experience) {
    try {
      _listBoardExperiences.firstWhere(
        (element) => element.experienceId == experience.experienceId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isDeletedExperienceInBoard(Experience experience) {
    try {
      _listBoardRemovedExperiences.firstWhere(
        (element) => element.experienceId == experience.experienceId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  makeBoardFadeInAnim() {
    if (!showGenerateItineraryButton) {
      Future.delayed(Duration(milliseconds: 200), () {
        showGenerateItineraryButton = true;
        showGenerateItineraryAnimDuration = 500;
        notifyListeners();
        Future.delayed(Duration(milliseconds: 200), () {
          showGenerateItineraryAnimDuration = 0;
        });
      });
    }
  }

  /// Loads the itinerary data and sets up a listener to turn off the loading state
  /// when the itinerary is loaded
  loadItineraryData() {
    if (trail.itineraryId <= 0 || trail.experiences.isEmpty) {
      _updatingItinerary = false;
      notifyListeners();
      return;
    }

    _updatingItinerary = true;
    notifyListeners();

    // Trigger the API call to get the updated itinerary
    _trailService.getItinerary(trail.itineraryId);

    // Cancel any existing subscription
    _itinerarySubscription?.cancel();

    // Set up a listener to turn off the loading state when the itinerary is loaded
    _itinerarySubscription = _trailService.itineraryStreamController.stream.listen((response) {
      if (_updatingItinerary) {
        _log.info('Turning off loading state in loadItineraryData - received response');
        _updatingItinerary = false;
        notifyListeners();
      }
    });
  }



  Future<void> updateItineraryStartDate(DateTime startDate, int adultCount, int teenCount, int kidCount) async {
    _updatingItinerary = true;
    notifyListeners();

    final response = await _trailService.updateItinerary(
      trail.itineraryId,
      startDate,
      adultCount,
      teenCount,
      kidCount,
    );

    if (mounted) {
      if (!response.result) {
        _updatingItinerary = false;
        notifyListeners();
        ScaffoldMessenger.of(_context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(_context)!.somethingWentWrongText),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.fixed,
          ),
        );
      } else {
        loadItineraryData();
      }
    }
  }

  void loadMapActivities(Map<String, List<dynamic>> scheduleDays, int selectedDayIndex) {
    dayActivities = [];
    scheduleDays.forEach((key, value) {
      value.forEach((element) {
        if (element is VisitItineraryEvent) {
          element.experience.visitTime = key;
          element.experience.isVisitEvent = true;
        }
        dayActivities.add(element);
      });
    });
  }

  Future<Trail?> _updateTrailExperiences(List<Experience> experiences) async {
    try {
      await trailLock.lock();
      var body = {"experience_ids": experiences.map((e) => e.experienceId).toList()};
      var response = await _trailService.updateTrail(body, trail.id);
      if (response.statusCode != 200) {
        return null;
      }
      return response.responseObject;
    } finally {
      trailLock.unlock();
    }
  }
}

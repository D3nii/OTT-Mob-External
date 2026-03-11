import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/visit_itinerary_event.dart';
import 'package:rxdart/rxdart.dart';

class SchedulePageViewModel extends BaseModel {
  bool _scheduleIsNotEmpty = false;
  final Itinerary itinerary;
  final ControllerPageBoardAndItineraryModel
      _controllerPageBoardAndItineraryModel;
  int _index = 0;
  Map<String, List<dynamic>> scheduleDays = {};
  PageController _listViewTrailItineraryController = PageController();
  StreamController<String> _itineraryStatus = StreamController.broadcast();
  bool _isIOS13 = false;
  StreamController<String> itineraryStatusStream = BehaviorSubject();
  final TrailService _trailService;

  SchedulePageViewModel(this._controllerPageBoardAndItineraryModel,
      this.itinerary, this._trailService);

  Stream<String> get itineraryStatus => _itineraryStatus.stream;

  // Public access to page controller
  PageController get listViewItineraryController =>
      _listViewTrailItineraryController;

  // Public access to current index
  int get index => _index;

  // Public access to schedule state
  bool get scheduleIsNotEmpty => _scheduleIsNotEmpty;

  // Direct field access for controller
  ControllerPageBoardAndItineraryModel
      get controllerPageBoardAndItineraryModel =>
          _controllerPageBoardAndItineraryModel;

  bool get isIOS13 => _isIOS13;

  // Simple setters that update state
  void updateScheduleIsNotEmpty(bool value) {
    _scheduleIsNotEmpty = value;
    notifyListeners();
  }

  void updateIndex(int value) {
    _index = value;
    notifyListeners();
  }

  set isIOS13(bool value) {
    _isIOS13 = value;
    notifyListeners();
  }

  Future<bool> platform() async {
    if (Platform.isIOS) {
      var deviceInfo = DeviceInfoPlugin();
      var iosInfo = await deviceInfo.iosInfo;
      var version = double.parse(iosInfo.systemVersion);
      if (version >= 13) {
        // return true;
        isIOS13 = true;
      } else {
        isIOS13 = false;
      }
    }
    return false;
  }

  init(BuildContext context) async {
    platform();

    itinerary.events.sort((a, b) {
      return a.position.compareTo(b.position);
    });

    scheduleDays = {};
    Map<String, List<dynamic>> tempDays = {};
    itinerary.events.forEach((element) {
      String dayFormatDate = DateFormat('EEE, MMM d').format(element.startTime);
      List dayItems = (tempDays[dayFormatDate] ?? [])..add(element);
      tempDays[dayFormatDate] = dayItems;
    });

    // Process each day for meal/sleep injection
    tempDays.forEach((day, events) {
      List processedEvents = [];

      // Identify actual visits for condition checking
      List<VisitItineraryEvent> visits = events
          .whereType<VisitItineraryEvent>()
          .where((e) => !e.experience.foodDrinks && !e.experience.accommodation)
          .toList();

      bool needsBreakfast = visits.any((e) {
        int start = e.startTime.toUtc().subtract(const Duration(hours: 6)).hour;
        int end = e.endTime.toUtc().subtract(const Duration(hours: 6)).hour;
        return start < 12 && end >= 9;
      });
      bool needsLunch = visits.any((e) {
        int start = e.startTime.toUtc().subtract(const Duration(hours: 6)).hour;
        int end = e.endTime.toUtc().subtract(const Duration(hours: 6)).hour;
        return start < 20 && end >= 12;
      });
      bool needsDinner = visits.any((e) {
        int end = e.endTime.toUtc().subtract(const Duration(hours: 6)).hour;
        return end >= 20;
      });

      bool breakfastAdded = false;
      bool lunchAdded = false;
      bool dinnerAdded = false;

      for (var event in events) {
        if (event is VisitItineraryEvent &&
            !event.experience.foodDrinks &&
            !event.experience.accommodation) {
          int startHour =
              event.startTime.toUtc().subtract(const Duration(hours: 6)).hour;
          int endHour =
              event.endTime.toUtc().subtract(const Duration(hours: 6)).hour;

          if (needsBreakfast &&
              !breakfastAdded &&
              (startHour >= 9 || endHour >= 9)) {
            processedEvents.add(_createInjectedMeal('Breakfast', '30 minutes',
                true, event.startTime.subtract(const Duration(minutes: 5))));
            breakfastAdded = true;
          }
          if (needsLunch && !lunchAdded && (startHour >= 12 || endHour >= 12)) {
            processedEvents.add(_createInjectedMeal('Lunch', '30 minutes', true,
                event.startTime.subtract(const Duration(minutes: 5))));
            lunchAdded = true;
          }
          if (needsDinner &&
              !dinnerAdded &&
              (startHour >= 20 || endHour >= 20)) {
            processedEvents.add(_createInjectedMeal('Dinner', '30 minutes',
                true, event.startTime.subtract(const Duration(minutes: 5))));
            dinnerAdded = true;
          }
        }
        processedEvents.add(event);
      }

      // Fallbacks
      if (needsLunch && !lunchAdded) {
        processedEvents.add(_createInjectedMeal('Lunch', '30 minutes', true,
            DateTime.now())); // Time not critical for fallback display
      }
      if (needsDinner && !dinnerAdded) {
        processedEvents.add(
            _createInjectedMeal('Dinner', '30 minutes', true, DateTime.now()));
      }

      // Always add Sleep at the end
      processedEvents
          .add(_createInjectedMeal('Sleep', '8 hours', false, DateTime.now()));

      scheduleDays[day] = processedEvents;
    });

    notifyListeners();
  }

  VisitItineraryEvent _createInjectedMeal(
      String name, String description, bool isMeal, DateTime time) {
    return VisitItineraryEvent(
      position: -1,
      startTime: time,
      endTime: time.add(Duration(minutes: isMeal ? 30 : 480)),
      experience: Experience.dummy(
        title: name,
        name: name,
        description: description,
        isMeal: isMeal,
      ),
    );
  }

  void previousPageTrailView(int index) {
    if (index > 0) {
      index = index - 1;
      _controllerPageBoardAndItineraryModel.index = index;
      _moveTo(_controllerPageBoardAndItineraryModel.index);
    }
  }

  void nextPageTrailView(int index) {
    if (index < scheduleDays.length - 1) {
      index = index + 1;
      _controllerPageBoardAndItineraryModel.index = index;
      _moveTo(_controllerPageBoardAndItineraryModel.index);
    }
  }

  void _moveTo(int index) {
    _listViewTrailItineraryController.animateToPage(index,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _itineraryStatus.close();
    itineraryStatusStream.close();
    super.dispose();
  }

  Future<bool> markExperienceAsNotVisited(
      BuildContext context, int experienceInTrailId) async {
    var data = {
      'id': experienceInTrailId,
      'visited_on_itinerary': false,
    };
    setState(ViewState.Busy);
    bool success =
        await _trailService.updateItineraryExperience(itinerary.id, data);
    if (!success) {
      await Dialogs.showSomethingWentWrongDialog(context);
      setState(ViewState.Idle);
      return false;
    }
    setState(ViewState.Idle);
    return true;
  }
}

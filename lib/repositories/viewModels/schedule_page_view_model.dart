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
      if (element is VisitItineraryEvent) {
        element.experience.visitStartTime = element.startTime;
        element.experience.visitEndTime = element.endTime;
      }
      String dayFormatDate = DateFormat('EEE, MMM d').format(element.startTime);
      List dayItems = (tempDays[dayFormatDate] ?? [])..add(element);
      tempDays[dayFormatDate] = dayItems;
    });

    // Process each day for meal/sleep injection
    tempDays.forEach((dayKey, events) {
      // TODO: Remove hardcoded test data once backend is ready
      itinerary.mealLocations[dayKey] = {
        'breakfast': {
          'name': 'Sunrise Bistro & Cafe',
          'url': 'https://www.google.com/maps',
          'image': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&q=80&w=200',
        },
        'lunch': {
          'name': 'Green Garden Grill',
          'url': 'https://www.google.com/maps',
          'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=200',
        },
        'dinner': {
          'name': 'Starlight Gourmet Dining',
          'url': 'https://www.google.com/maps',
          'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=200',
        }
      };
      itinerary.sleepLocations[dayKey] = {
        'name': 'Grand Heritage Resort & Spa',
        'url': 'https://www.google.com/maps',
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=200',
      };

      List processedEvents = [];

      // Identify actual visits for condition checking
      List<VisitItineraryEvent> visits = events
          .whereType<VisitItineraryEvent>()
          .where((e) => !e.experience.foodDrinks && !e.experience.accommodation)
          .toList();

      bool hasActivity9to12 = visits.any((e) {
        return e.startTime.hour < 12 && e.endTime.hour >= 9;
      });
      bool hasActivity12to20 = visits.any((e) {
        return e.startTime.hour < 20 && e.endTime.hour >= 12;
      });

      bool breakfastAdded = false;
      bool lunchAdded = false;
      bool dinnerAdded = false;

      for (var event in events) {
        if (event is VisitItineraryEvent &&
            !event.experience.foodDrinks &&
            !event.experience.accommodation) {
          int startHour = event.startTime.hour;

          // Breakfast: Injected before first visit at/after 9:00 AM, 
          // if activity between 9:00 AM and 12:00 PM
          if (!breakfastAdded && startHour >= 9 && hasActivity9to12) {
            processedEvents.add(_createInjectedMeal('Breakfast', '30 minutes',
                true, event.startTime.subtract(const Duration(minutes: 5)), dayKey, 'breakfast'));
            breakfastAdded = true;
          }
          
          // Lunch: Injected before first visit at/after 12:00 PM, 
          // if activity between 12:00 PM and 8:00 PM
          if (!lunchAdded && startHour >= 12 && hasActivity12to20) {
            processedEvents.add(_createInjectedMeal('Lunch', '30 minutes', true,
                event.startTime.subtract(const Duration(minutes: 5)), dayKey, 'lunch'));
            lunchAdded = true;
          }
          
          // Dinner: Injected before first visit at/after 8:00 PM
          if (!dinnerAdded && startHour >= 20) {
            processedEvents.add(_createInjectedMeal('Dinner', '30 minutes',
                true, event.startTime.subtract(const Duration(minutes: 5)), dayKey, 'dinner'));
            dinnerAdded = true;
          }
        }
        processedEvents.add(event);
      }

      // Always add Sleep at the end
      processedEvents.add(_createInjectedMeal('Sleep', '8 hours', false, DateTime.now(), dayKey, 'sleep'));

      scheduleDays[dayKey] = processedEvents;
    });

    notifyListeners();
  }

  VisitItineraryEvent _createInjectedMeal(
      String name, String description, bool isMeal, DateTime time, String dayKey, String mealType) {
    
    String? adName;
    String? adUrl;
    String? adImageUrl;

    // Use the dayKey format from itinerary data if available, 
    // but fall back to searching for a matching date string
    String lookupKey = dayKey;
    
    if (isMeal) {
      final dayMeals = itinerary.mealLocations[lookupKey];
      if (dayMeals != null && dayMeals[mealType] != null) {
        final adData = dayMeals[mealType];
        adName = adData['name'];
        adUrl = adData['url'];
        adImageUrl = adData['image'];
      }
    } else if (mealType == 'sleep') {
      final adData = itinerary.sleepLocations[lookupKey];
      if (adData != null) {
        adName = adData['name'];
        adUrl = adData['url'];
        adImageUrl = adData['image'];
      }
    }

    final eventEndTime = time.add(Duration(minutes: isMeal ? 30 : 480));
    final experience = Experience.dummy(
      title: name,
      name: name,
      description: description,
      isMeal: isMeal,
      adName: adName,
      adUrl: adUrl,
      adImageUrl: adImageUrl,
    );
    
    // Sync times to experience for display in card
    experience.visitStartTime = time;
    experience.visitEndTime = eventEndTime;

    return VisitItineraryEvent(
      position: -1,
      startTime: time,
      endTime: eventEndTime,
      experience: experience,
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

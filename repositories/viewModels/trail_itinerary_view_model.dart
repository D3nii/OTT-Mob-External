import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';

class TrailItineraryViewModel extends BaseModel {
  Itinerary? _itinerary;
  final TrailService _trailService;
  ControllerPageBoardAndItineraryModel? _controllerPageBoardAndItineraryModel;
  bool _showItinerarieMap = false;
  StreamSubscription<ApplicationApiResponse<Itinerary>>? _itinerarySubscription;

  late PageController listViewController;

  TrailItineraryViewModel(this._trailService);

  // Public access to services and models
  TrailService get trailService => _trailService;
  Itinerary? get itinerary => _itinerary;
  ControllerPageBoardAndItineraryModel? get controllerPageBoardAndItineraryModel => _controllerPageBoardAndItineraryModel;
  bool get showItinerarieMap => _showItinerarieMap;

  // Update methods with proper state management
  void updateItinerary(Itinerary value) {
    _itinerary = value;
    notifyListeners();
  }

  void updateControllerPageBoardAndItineraryModel(ControllerPageBoardAndItineraryModel value) {
    _controllerPageBoardAndItineraryModel = value;
    notifyListeners();
  }

  set showItinerarieMap(bool value) {
    _showItinerarieMap = value;
    notifyListeners();
  }

  void init() {
    notifyListeners();
  }

  /// Sets up a listener for the itinerary stream
  void listenToItineraryChanges() {
    // Create a subscription to the itinerary stream
    _itinerarySubscription = _trailService.itineraryStreamController.stream.listen((response) {
      // Update the itinerary when new data arrives
      updateItinerary(response.responseObject);
    });
  }

  @override
  void dispose() {
    // Clean up the subscription when the model is disposed
    _itinerarySubscription?.cancel();
    super.dispose();
  }
}

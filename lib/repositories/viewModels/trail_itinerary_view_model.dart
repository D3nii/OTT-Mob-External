import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/visit_itinerary_event.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';

class TrailItineraryViewModel extends BaseModel {
  Itinerary? _itinerary;
  final TrailService _trailService;
  ControllerPageBoardAndItineraryModel? _controllerPageBoardAndItineraryModel;
  bool _showItinerarieMap = false;
  StreamSubscription<ApplicationApiResponse<Itinerary>>? _itinerarySubscription;

  late PageController listViewController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  GoogleMapController? _googleMapController;
  late final GoogleMapPolyline _googleMapPolyline;
  final String _googleMapsApiKey;

  TrailItineraryViewModel(this._trailService, this._googleMapsApiKey) {
    _googleMapPolyline = GoogleMapPolyline(apiKey: _googleMapsApiKey);
  }

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
      _updateMapData();
    });
  }

  void onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    _updateMapData();
  }

  Future<void> _updateMapData() async {
    if (_itinerary == null || _itinerary!.id <= 0) return;

    markers.clear();
    List<Experience> experiences = [];

    // Extract experiences from the itinerary
    for (var event in _itinerary!.events) {
      if (event is VisitItineraryEvent) {
        experiences.add(event.experience);
        markers.add(Marker(
          markerId: MarkerId(event.experience.experienceId.toString()),
          position: LatLng(event.experience.latitude, event.experience.longitude),
          infoWindow: InfoWindow(title: event.experience.name),
        ));
      }
    }

    if (experiences.isNotEmpty && _googleMapController != null) {
      // Fit bounds logic or just center on first
      _googleMapController!.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(experiences.first.latitude, experiences.first.longitude),
        12,
      ));
    }

    await _getPolyLines(experiences);
    notifyListeners();
  }

  Future<void> _getPolyLines(List<Experience> experiences) async {
    polylines.clear();
    for (var i = 0; i < experiences.length - 1; i++) {
      var start = experiences[i];
      var end = experiences[i + 1];
      var route = await _googleMapPolyline.getCoordinatesWithLocation(
          destination: LatLng(end.latitude, end.longitude),
          origin: LatLng(start.latitude, start.longitude),
          mode: RouteMode.driving);

      if (route != null) {
        polylines.add(Polyline(
          polylineId: PolylineId("${start.experienceId}_${end.experienceId}"),
          points: route,
          color: tomato,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ));
      }
    }
  }

  @override
  void dispose() {
    // Clean up the subscription when the model is disposed
    _itinerarySubscription?.cancel();
    super.dispose();
  }
}

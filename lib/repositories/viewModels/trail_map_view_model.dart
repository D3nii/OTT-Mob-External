import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/visit_itinerary_event.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/repositories/viewModels/trail_itinerary_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/utils/map_marker_utils.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class TrailMapViewModel extends BaseModel {
  static final Logger _logger = Logger('TrailMapViewModel');
  BitmapDescriptor? _pinLocationIcon;
  final ControllerPageBoardAndItineraryModel controllerPageBoardAndItineraryModel;
  GoogleMapController? _googleMapController;
  late final GoogleMapPolyline _googleMapPolyline;
  LatLng? firstPinned;
  final List dayActivities;
  final List<Experience> _experiences = [];
  final List<LatLng> _geoPoints = [];
  final ScrollController scrollController = ScrollController();
  final Set<Marker> markers = {};
  final Set<Polyline> polyline = {};
  final SnappingPosition snappingSheetPositionCollapsed = SnappingPosition.pixels(
    snappingCurve: Curves.fastLinearToSlowEaseIn,
    snappingDuration: const Duration(milliseconds: 500),
    positionPixels: 152,
  );
  final SnappingPosition snappingSheetPositionExpanded = SnappingPosition.factor(
    positionFactor: 0.8,
    snappingCurve: Curves.easeOutExpo,
    snappingDuration: const Duration(milliseconds: 500),
  );
  TrailItineraryViewModel? trailItineraryViewModel;
  final SnappingSheetController snappingSheetController = SnappingSheetController();
  int _currentExperienceIndex = 0;
  int totalSecond = 0;
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  set isExpanded(bool value) {
    _isExpanded = value;
    notifyListeners();
  }

  int get currentExperienceIndex => _currentExperienceIndex;

  set currentExperienceIndex(int value) {
    _currentExperienceIndex = value;
    notifyListeners();
  }

  List<Experience> get experiences => _experiences;

  List<LatLng> get geoPoints => _geoPoints;

  TrailMapViewModel(this.dayActivities, this.controllerPageBoardAndItineraryModel, String googleMapsApiKey) {
    _googleMapPolyline = GoogleMapPolyline(apiKey: googleMapsApiKey);
  }

  init(GoogleMapController googleMapController) async {
    _googleMapController = googleMapController;
    try {
      // Create a custom pink marker using the app's pink color
      _pinLocationIcon = await MapMarkerUtils.createPinkMarker();

      dayActivities.forEach((element) {
        if (element is VisitItineraryEvent) {
          element.experience.visitStartTime = element.startTime;
          _experiences.add(element.experience);
          LatLng position = new LatLng(element.experience.latitude, element.experience.longitude);
          _geoPoints.add(position);
          createMarker(position, "${element.experience.experienceId}");
        }
      });
      notifyListeners();
      await getPolyLines();
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize map with markers and polylines', e, stackTrace);
      // Continue without markers/polylines if there's an error
      notifyListeners();
    }
  }

  void createMarker(LatLng position, String name) {
    Marker newMarker = Marker(
        markerId: MarkerId("$name"),
        position: position,
        icon: _pinLocationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta));
    markers.add(newMarker);
  }

  Future<void> getPolyLines() async {
    this.polyline.clear();
    try {
      await googlePolyline();
    } catch (e, stackTrace) {
      _logger.severe('Failed to get polylines', e, stackTrace);
      // Continue without polylines if there's an error
    }
    notifyListeners();
  }

  Future<void> googlePolyline() async {
    late Experience start;
    late Experience end;
    for (var i = 0; i < _experiences.length; i++) {
      if (i + 1 < _experiences.length) {
        start = _experiences[i];
        end = _experiences[i + 1];
        try {
          var route = await _googleMapPolyline.getCoordinatesWithLocation(
              destination: LatLng(end.latitude, end.longitude),
              origin: LatLng(start.latitude, start.longitude),
              mode: RouteMode.driving);

          if (route != null) {
            this.polyline.add(Polyline(
                polylineId: PolylineId(start.experienceId.toString()),
                visible: true,
                points: route,
                color: pigPinkTwo,
                width: 3,
                startCap: Cap.roundCap,
                endCap: Cap.buttCap));
          }
        } catch (e, stackTrace) {
          _logger.warning('Failed to get polyline for route from ${start.experienceId} to ${end.experienceId}', e, stackTrace);
          // Continue with other polylines
        }
      }
    }
  }

  String getStartTime(DateTime startTimeStamp) {
    return DateFormat('hh:mmaaa').format(startTimeStamp);
  }

  void moveCameraToExperience(int index) {
    if (_googleMapController != null && index < _experiences.length) {
      _googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(_experiences[index].latitude, _experiences[index].longitude), zoom: 15)));
    }
  }

  void collapseSnappingSheet() {
    snappingSheetController.snapToPosition(snappingSheetPositionCollapsed);
  }
}

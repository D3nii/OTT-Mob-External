import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/repositories/enums/trail_status.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/utils/map_marker_utils.dart';

class PreviewTrailModel extends BaseModel {
  Trail _currentTrailPreview = Trail(
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
  BitmapDescriptor? _pinLocationIcon;
  int? _totalSuggestedTrails;
  late TrailService _trailService;
  late ProfileService _profileService;
  bool _showTrailAdded = false;
  bool _addRequested = false;
  int? _trailId;
  bool _isAdded = true;
  bool _error = false;
  Duration _duration = Duration.zero;

  bool get showTrailAdded => _showTrailAdded;

  get addRequested => _addRequested;

  Trail get currentTrailPreview => _currentTrailPreview;

  BitmapDescriptor? get pinLocationIcon => _pinLocationIcon;

  int? get totalSuggestedTrails => _totalSuggestedTrails;

  int? get trailId => _trailId;

  bool get isAdded => _isAdded;

  bool get error => _error;

  Duration get duration => _duration;

  set error(bool value) {
    _error = value;
    notifyListeners();
  }

  set isAdded(bool value) {
    _isAdded = value;
    notifyListeners();
  }

  set trailId(int? value) {
    _trailId = value;
    notifyListeners();
  }

  set currentTrailPreview(Trail trail) {
    _currentTrailPreview = trail;
    notifyListeners();
    }

  set pinLocationIcon(BitmapDescriptor? pinLocationIcon) {
    if (pinLocationIcon != _pinLocationIcon) {
      _pinLocationIcon = pinLocationIcon;
      notifyListeners();
    }
  }

  PreviewTrailModel(this._trailService, this._profileService);

  initState(Trail trail) async {
    if (state == ViewState.Busy) {
      return;
    }
    currentTrailPreview = trail;
    // Create a custom pink marker using the app's pink color
    pinLocationIcon = await MapMarkerUtils.createPinkMarker();
    showTrailDetails(trail, false);
  }

  Set<Marker> getMarkers({required Trail trail}) {
    Set<Marker> trailMarkers = Set();
    for (Experience exp in trail.experiences) {
      Marker newMarker = Marker(
          markerId: MarkerId(exp.experienceId.toString()),
          alpha: 1.0,
          position: LatLng(exp.latitude, exp.longitude),
          icon: _pinLocationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta));
      trailMarkers.add(newMarker);
    }
      return trailMarkers;
  }

  Future<void> showTrailDetails(Trail trail, bool delayed) async {
    setState(ViewState.Busy);

    if (delayed) {
      await Future.delayed(Duration(seconds: 1));
    }

    BaseResponse<Trail> response = await _trailService.getTrailDetails(trailId: trail.id);

    showErrorStatus = response.responseStatus == ERROR;
    if (!showErrorStatus && mounted) {
      _duration = response.data.itineraryEstimatedTime;
      currentTrailPreview = response.data;
      notifyListeners();
    }
    setState(ViewState.Idle);
  }

  void onTrailMapCreated(GoogleMapController controller) {
    controller.animateCamera(CameraUpdate.newLatLngBounds(currentTrailPreview.mapBounds, 50));
    }

  Future<bool> addCurrentTrailToCollection(BuildContext context) async {
    _addRequested = true;
    notifyListeners();

    var data = {
      'name': currentTrailPreview.name,
      'description': currentTrailPreview.description,
      'collaborators': [],
      'experience_ids': currentTrailPreview.experiences.map((e) => e.experienceId).toList()
    };

    BaseResponse<Trail> response = await _trailService.createTrail(data);

    if (response.responseStatus != SUCCESS) {
      isAdded = false;
      trailId = null;
      error = true;
      notifyListeners();
      return false;
    }

    // Pop views until root.
    // Then, navigate to the details page of the created trail.
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushNamed(context, '/private-trail', arguments: response.data);

    return true;
  }

  addExperienceCallback({
    int? experienceId,
  }) {}

  moreOptionsExperienceCallback({
    int? experienceId,
  }) {}

  @override
  void dispose() {
    super.dispose();
  }

  Future<ApplicationApiResponse> deleteCurrentTrailFromCollection() async {
    Trail trail = Trail(
      id: trailId ?? 0,
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
    ApplicationApiResponse responseFromTheApiObject = await _trailService.deleteTrail(trail);
    return responseFromTheApiObject;
  }

  ProfileService get profileService => _profileService;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/ui/views/trail_preview/trail_preview_view.dart';
import 'package:onetwotrail/utils/map_marker_utils.dart';
import 'package:rxdart/rxdart.dart';

class DiscoverModel extends BaseModel {

  final DiscoveryService _discoveryService;
  bool _suggestedExpanded = true;
  BitmapDescriptor? _pinLocationIcon;
  Map<String, dynamic> filters = {};
  int? _totalSuggestedTrails;
  Stream<BaseResponse<Map<String, dynamic>>>? discoverDataResponse;
  StreamController<Map<String, dynamic>> _filtersStreamController = StreamController.broadcast();
  late HomeModel _homeModel;
  User? _user;
  FocusNode _focusNode = FocusNode();
  late StreamController<List<Trail>> _suggestedTrailController;
  StreamSubscription? _discoverListener;
  String? _nextPageToken;
  bool _gettingPage = false;
  int _viewIndex = 0;
  BaseResponse<Map<String, dynamic>> lastServiceResponse = BaseResponse({}, 'START');

  DiscoverModel(this._discoveryService);

  int get viewIndex => _viewIndex;

  String? get nextPageToken => _nextPageToken;

  bool get suggestedExpanded => _suggestedExpanded;

  StreamController<List<Trail>> get suggestedTrailController => _suggestedTrailController;

  BitmapDescriptor? get pinLocationIcon => _pinLocationIcon;

  int? get totalSuggestedTrails => _totalSuggestedTrails;

  HomeModel get homeModel => _homeModel;

  User? get user => _user;

  FocusNode get focusNode => _focusNode;

  get filtersStream => _filtersStreamController.stream;

  set focusNode(FocusNode value) {
    _focusNode = value;
    notifyListeners();
  }

  set user(User? value) {
    _user = value;
    notifyListeners();
  }

  set homeModel(HomeModel value) {
    _homeModel = value;
    notifyListeners();
  }

  set suggestedExpanded(bool suggestedExpanded) {
    if (suggestedExpanded != _suggestedExpanded) {
      _suggestedExpanded = suggestedExpanded;
      notifyListeners();
    }
  }

  set pinLocationIcon(BitmapDescriptor? pinLocationIcon) {
    if (pinLocationIcon != _pinLocationIcon) {
      _pinLocationIcon = pinLocationIcon;
      notifyListeners();
    }
  }

  Future<DiscoverModel> initState() async {
    _nextPageToken = null;
    lastServiceResponse = BaseResponse({}, 'RESET');
    discoverDataResponse = null;
    _discoveryService.initialize();
      discoverDataResponse = _discoveryService.discoveryResponses;
    _discoveryService.getDiscoveryPage(pageToken: _nextPageToken).then((nextPageToken) {
      _nextPageToken = nextPageToken;
      _gettingPage = false;
    });
    _suggestedTrailController = BehaviorSubject();
    // Create a custom pink marker using the app's pink color
    pinLocationIcon = await MapMarkerUtils.createPinkMarker();
    homeModel.discoverScrollController.addListener(_updateDiscoverScrollState);
    return this;
  }

  _updateDiscoverScrollState() {
    focusNode.requestFocus();
    // Get displayable height in pixels
    double displayableHeight = homeModel.discoverScrollController.position.viewportDimension;
    // Get the pixels left to scroll to reach the bottom
    double pixelsLeftToScroll = homeModel.discoverScrollController.position.maxScrollExtent -
        homeModel.discoverScrollController.position.pixels;
    // Whether the pixels left to scroll is less than the height of the displayable area
    bool tooFewPixelsLeft = pixelsLeftToScroll < displayableHeight;
    // Whether there is a next page to get
    bool hasNextPage = _nextPageToken != null && _nextPageToken!.isNotEmpty;
    // Whether should get the next page
    bool shouldGetNextPage = tooFewPixelsLeft && hasNextPage;
    if (shouldGetNextPage && !_gettingPage) {
      _gettingPage = true;
      _discoveryService.getDiscoveryPage(pageToken: _nextPageToken).then((page) {
        _nextPageToken = page;
        _gettingPage = false;
      });
    }
  }

  applyFilters(Map<String, dynamic> filters) {
    this.filters = filters;
    _viewIndex = filters.isEmpty ? 0 : 1;
    _filtersStreamController.add(filters);
    notifyListeners();
  }

  toggleSuggestedTrails() {
    suggestedExpanded = !suggestedExpanded;
  }

  onExpansionChanged(bool expanded) {
    suggestedExpanded = expanded;
    focusNode.requestFocus();
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

  showTrailDetails({required BuildContext context, required Trail trail}) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrailPreviewView(),
        fullscreenDialog: true,
      ),
    );
  }

  showShareDialog(Trail trail) {}

  @override
  void dispose() {
    _discoverListener?.cancel();
    _suggestedTrailController.close();
    super.dispose();
  }
}

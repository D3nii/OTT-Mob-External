import 'dart:async';

import 'package:onetwotrail/constants.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:rxdart/rxdart.dart';

class TrailService {
  late ApplicationApi applicationApi;
  late ApplicationApiResponse<Itinerary> itineraryResponse;
  StreamController<ApplicationApiResponse<Itinerary>>
      itineraryStreamController =
      BehaviorSubject<ApplicationApiResponse<Itinerary>>();
  late ApplicationApiResponse<List<Trail>> trailsResponse;
  StreamController<ApplicationApiResponse<List<Trail>>> trailsStreamController =
      BehaviorSubject<ApplicationApiResponse<List<Trail>>>();
  StreamController<bool> _loadingStateController = BehaviorSubject<bool>.seeded(false);

  String? _nextPageToken;
  List<Trail> _trails = [];
  bool _isLoadingTrails = false;
  bool _isInitialized = false;
  bool _hasLoadedOnce = false;

  TrailService(this.applicationApi);

  Stream<ApplicationApiResponse<List<Trail>>> initUserTrails() {
    if (!_isInitialized) {
      _isInitialized = true;
      loadTrailPage();
    }
    return trailsStreamController.stream;
  }

  bool get isInitialized => _isInitialized;

  Stream<bool> get loadingStateStream => _loadingStateController.stream;

  ApplicationApiResponse<Itinerary>? get currentItineraryResponse =>
      (itineraryStreamController as BehaviorSubject<ApplicationApiResponse<Itinerary>>).valueOrNull;

  void _setLoadingState(bool isLoading) {
    _isLoadingTrails = isLoading;
    _loadingStateController.add(isLoading);
  }

  Future<void> loadTrailPage() async {
    if (_isLoadingTrails || (_trails.isNotEmpty && !hasMoreTrails)) {
      return;
    }

    _setLoadingState(true);

    try {
      var rawResponse = await applicationApi.getUserTrails(
          pageSize: Constants.TRAILS_PAGE_SIZE, pageToken: _nextPageToken);
      _setLoadingState(false);

      if (rawResponse.result) {
        _trails.addAll(rawResponse.responseObject);
        _nextPageToken = rawResponse.nextPageToken;
        _hasLoadedOnce = true;

        var controllerResponse = ApplicationApiResponse<List<Trail>>(
          statusCode: rawResponse.statusCode,
          result: rawResponse.result,
          responseBody: rawResponse.responseBody,
          responseObject: List.from(_trails),
          nextPageToken: rawResponse.nextPageToken,
        );

        trailsResponse = controllerResponse;
        trailsStreamController.add(controllerResponse);
      }
    } catch (e) {
      _setLoadingState(false);

      var controllerResponse = ApplicationApiResponse<List<Trail>>(
        statusCode: 500,
        result: false,
        responseBody: e.toString(),
        responseObject: _trails,
      );
      trailsResponse = controllerResponse;
      trailsStreamController.add(controllerResponse);
    }
  }

  Future<void> loadNextTrailPage() async {
    await loadTrailPage();
  }

  bool get hasMoreTrails =>
      _nextPageToken != null && _nextPageToken!.isNotEmpty;

  bool get isLoadingTrails => _isLoadingTrails;

  bool get isInitialLoad => !_hasLoadedOnce && _trails.isEmpty && _isLoadingTrails;

  Future<BaseResponse<Trail>> getTrailDetails({required int trailId}) async {
    return await applicationApi.getTrail(trailId: trailId);
  }

  Future<BaseResponse<Trail>> createTrail(Map<String, Object> data) async {
    var response = await applicationApi.createTrail(data);
    if (response.responseStatus == SUCCESS) {
      _trails.insert(0, response.data);
      _updateTrailsStream();
    }
    return response;
  }

  Future<ApplicationApiResponse<Trail>> updateTrail(
      Map<String, Object> temporalTrail, int trailID) async {
    ApplicationApiResponse<Trail> response =
        await applicationApi.updateTrail(temporalTrail, trailID);
    if (response.statusCode == 200) {
      _replaceTrailInStream(response.responseObject);
    }
    return response;
  }

  Future<ApplicationApiResponse<void>> deleteTrail(Trail trail) async {
    var apiResult = await applicationApi.deleteTrail(trail);
    if (apiResult.statusCode >= 200 && apiResult.statusCode < 300) {
      _trails.removeWhere((element) => element.id == trail.id);
      _updateTrailsStream();
    }
    return apiResult as ApplicationApiResponse<void>;
  }

  Future<ApplicationApiResponse<Trail>> publishTrail(Trail trail) async {
    final response = await applicationApi.publishTrail(trail);
    if (response.statusCode == 200) {
      _replaceTrailInStream(response.responseObject);
    }
    return response;
  }

  Future<ApplicationApiResponse<Trail>> unpublishTrail(Trail trail) async {
    final apiResult = await applicationApi.unpublishTrail(trail);
    if (apiResult.statusCode == 200) {
      _replaceTrailInStream(apiResult.responseObject);
    }
    return apiResult;
  }

  void _updateTrailsStream() {
    var updatedResponse = ApplicationApiResponse<List<Trail>>(
      statusCode: 200,
      result: true,
      responseBody: trailsResponse.responseBody,
      responseObject: List.from(_trails),
      nextPageToken: _nextPageToken,
    );
    trailsResponse = updatedResponse;
    trailsStreamController.add(updatedResponse);
  }

  void _replaceTrailInStream(Trail trail) {
    for (int i = 0; i < _trails.length; i++) {
      if (_trails[i].id == trail.id) {
        _trails[i] = trail;
        break;
      }
    }
    _updateTrailsStream();
  }

  Future<bool> updateItineraryExperience(
      int itineraryId, Map<String, dynamic> experience) async {
    var requestBody = {
      "experiences_in_trail_attributes": [experience]
    };
    ApplicationApiResponse<Itinerary> response = await applicationApi
        .updateItineraryWithApplicationApiResponse(itineraryId, requestBody);
    if (response.result) {
      itineraryResponse = response;
      itineraryStreamController.add(response);
    }
    return response.result;
  }

  Future<ApplicationApiResponse<void>> updateTrailFromEditView(
      String name,
      String smallDescription,
      List<String> listOfCollaborators,
      int trailId,
      bool listOfCollaboratorsChange) async {
    var apiResult = await applicationApi.updateTrailFromFields(
        name,
        smallDescription,
        listOfCollaborators,
        trailId,
        listOfCollaboratorsChange);

    if (apiResult.statusCode >= 200 && apiResult.statusCode < 300) {
      await refreshTrails();
    }
    return apiResult as ApplicationApiResponse<void>;
  }

  Future<ApplicationApiResponse<Itinerary>> updateItinerary(int itineraryId,
      DateTime startTime, int adultCount, int teenCount, int kidCount) async {
    var requestBody = {
      "start_date": startTime.toIso8601String().split("T")[0],
      "adult_participants_count": adultCount,
      "teen_participants_count": teenCount,
      "kids_participants_count": kidCount,
    };
    ApplicationApiResponse<Itinerary> response = await applicationApi
        .updateItineraryWithApplicationApiResponse(itineraryId, requestBody);
    if (response.result) {
      itineraryResponse = response;
      itineraryStreamController.add(response);
    }
    return response;
  }

  Stream<ApplicationApiResponse<Itinerary>> getItinerary(int itineraryId) {
    applicationApi.getItinerary(itineraryId).then((value) {
      itineraryResponse = value;
      itineraryStreamController.add(value);
    });
    return itineraryStreamController.stream;
  }

  void _emitEmptyTrailsState() {
    trailsStreamController.add(ApplicationApiResponse<List<Trail>>(
      statusCode: 200,
      result: true,
      responseBody: '',
      responseObject: [],
    ));
  }

  Future<void> refreshTrails() async {
    _nextPageToken = null;
    _trails.clear();
    _isInitialized = false;
    _emitEmptyTrailsState();
    await loadTrailPage();
  }
}

import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class InsideShowModalBottomSheetModel extends BaseModel {
  final Experience experience;
  final TrailService _trailService;
  List<Trail> _trails = [];
  late StreamSubscription _responseListener;
  late StreamSubscription _loadingStateListener;
  bool _visible = true;
  bool _updatingTrail = false;
  late ScrollController _trailScrollController;
  bool _isInitialLoad = true;
  late Logger _log;

  bool get updatingTrail => _updatingTrail;

  bool get visible => _visible;

  List<Trail> get trails => _trails;

  set visible(bool value) {
    _visible = value;
    notifyListeners();
  }



  InsideShowModalBottomSheetModel(this.experience, this._trailService) {
    _responseListener = Stream<ApplicationApiResponse<List<Trail>>>.empty().listen((_) {});
    _loadingStateListener = Stream<bool>.empty().listen((_) {});
    _log = Logger('InsideShowModalBottomSheetModel');
    _trailScrollController = ScrollController();
    _trailScrollController.addListener(_updateTrailScrollState);
  }

  Future<bool> setChecked(int trailId) async {
    _updatingTrail = true;
    // Find the trail with the given ID
    Trail? trail;
    try {
      trail = trails.firstWhere((element) => element.id == trailId);
    } catch (e) {
      // Trail not found
      _updatingTrail = false;
      return false;
    }

    trail.experiences.add(experience);
    notifyListeners();

    var data = {'experience_ids': trail.experiences.map((trailExperience) => trailExperience.experienceId).toList()};

    ApplicationApiResponse<Trail> result = await _trailService.updateTrail(data, trailId);
    if (result.statusCode != 200) {
      trail.experiences.removeWhere((element) => element.experienceId == experience.experienceId);
      if (mounted) {
        notifyListeners();
      }
    }

    _updatingTrail = false;
    return result.statusCode == 200;
  }

  Future<bool> setUnchecked(int trailId) async {
    _updatingTrail = true;
    // Find the trail with the given ID
    Trail? trail;
    try {
      trail = trails.firstWhere((element) => element.id == trailId);
    } catch (e) {
      // Trail not found
      _updatingTrail = false;
      return false;
    }

    trail.experiences.removeWhere((element) => element.experienceId == experience.experienceId);
    notifyListeners();

    var data = {'experience_ids': trail.experiences.map((trailExperience) => trailExperience.experienceId).toList()};

    ApplicationApiResponse<Trail> result = await _trailService.updateTrail(data, trailId);

    if (result.statusCode != 200) {
      trail.experiences.add(experience);
      if (mounted) {
        notifyListeners();
      }
    }
    _updatingTrail = false;
    return result.statusCode == 200;
  }

  startListeningTrails() async {
    var trailsStream = _trailService.initUserTrails();

    await _responseListener.cancel();
    await _loadingStateListener.cancel();

    _responseListener = trailsStream.listen((event) {
      _trails = event.responseObject;
      _isInitialLoad = false;
      notifyListeners();
      
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _updateTrailScrollState();
      });
    });

    _loadingStateListener = _trailService.loadingStateStream.listen((_) {
      notifyListeners();
    });
  }

  void _updateTrailScrollState() {
    if (!_trailScrollController.hasClients) return;
    if (isLoadingMoreTrails) return;
    if (!hasMoreTrails) return;

    double maxScrollExtent = _trailScrollController.position.maxScrollExtent;
    double currentScroll = _trailScrollController.position.pixels;
    double displayableHeight = _trailScrollController.position.viewportDimension;
    
    double pixelsLeftToScroll = maxScrollExtent - currentScroll;
    double threshold = displayableHeight;
    bool shouldLoadMore = pixelsLeftToScroll <= threshold;

    if (shouldLoadMore) {
      loadMoreTrails();
    }
  }

  void loadMoreTrails() {
    if (!hasMoreTrails || _trailService.isLoadingTrails) return;

    _trailService.loadTrailPage().catchError((e) {
      _log.warning('Failed to load more trails: $e');
    });
  }

  bool get isLoadingMoreTrails => _isInitialLoad || _trailService.isLoadingTrails;

  bool get hasMoreTrails => _trailService.hasMoreTrails;

  ScrollController get trailScrollController => _trailScrollController;

  bool get hasPaginationError {
    try {
      return _trailService.trailsResponse.result == false;
    } catch (e) {
      return false;
    }
  }

  String? get paginationError {
    if (!hasPaginationError) return null;
    try {
      return _trailService.trailsResponse.responseBody;
    } catch (e) {
      return null;
    }
  }

  void retryPagination() {
    _trailService.loadTrailPage().catchError((e) {
      _log.warning('Failed to retry pagination: $e');
    });
  }

  @override
  void dispose() {
    _trailScrollController.removeListener(_updateTrailScrollState);
    _trailScrollController.dispose();
    _responseListener.cancel();
    _loadingStateListener.cancel();
    super.dispose();
  }

  getImagesFromExperiencesInTrail(Trail trail) {
    List<String> images = [];
    if (trail.experiences.isNotEmpty) {
      for (Experience value in trail.experiences) {
        images.add(value.imageUrls.first);
      }
    }
    return images;
  }
}

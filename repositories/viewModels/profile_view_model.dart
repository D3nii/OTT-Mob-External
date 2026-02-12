import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/anonymous.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/utils/hide_bottom_tabBar.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ProfileViewModel extends BaseModel {
  late ProfileService profileService;
  Stream<BaseResponse<User>>? profile;

  late TrailService trailService;
  List<Trail>? trails;
  StreamController<List<Trail>> trailStream = BehaviorSubject();
  late StreamSubscription _loadingStateListener;

  late HideBottomTabBar _hideBottomTabBar;
  late HomeModel _homeModel;

  final _log = Logger('ProfileViewModel');

  ProfileViewModel(BuildContext context) {
    _log.info('Initializing profile view model');
    // Init the profile service using the providers of the context.
    profileService = Provider.of<ProfileService>(context, listen: false);
    // Init the trail service using the providers of the context.
    trailService = Provider.of<TrailService>(context, listen: false);
    _hideBottomTabBar = Provider.of<HideBottomTabBar>(context, listen: false);
    _homeModel = Provider.of<HomeModel>(context, listen: false);

    // Use HomeModel's scroll controller with pagination listener
    _homeModel.profileScrollController.addListener(_updateTrailScrollState);

    var apiContext =
        Provider.of<ApplicationApi>(context, listen: false).context;
    _log.info(
        'Checking user authentication status: ${apiContext.hasToken ? 'authenticated' : 'not authenticated'}');

    runBasedOnUser(context, onRegistered: () {
      _log.info('Loading user profile and trails');
      return initRegisteredUser();
    }, onUnregistered: () {
      _log.info('Skipping profile initialization for unauthenticated user');
      return doNothing();
    });
  }

  Future<void> initRegisteredUser() async {
    _log.info('Fetching user profile information...');
    profile = profileService.getProfileInfo();

    // Add a listener to log the user data when it's received
    profile?.listen((userData) {
      _log.info('Got user profile data: ${userData.responseStatus}');
      _log.info('User country code: "${userData.data.country}"');
    });

    _log.info('Requesting user trails...');
    var trailsStream = trailService.initUserTrails();

    trailsStream.listen((event) async {
      if (event.result == true) {
        trails = event.responseObject;
        _log.info('Got ${trails?.length ?? 0} user trails');
        trailStream.add(trails ?? []);
        
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _updateTrailScrollState();
        });
      } else {
        _log.warning('Failed to fetch user trails: ${event.responseBody}');
      }
    });

    _loadingStateListener = trailService.loadingStateStream.listen((_) {
      notifyListeners();
    });

    _log.info('Updating UI with user profile data...');
    notifyListeners();
  }

  void hideBottomBar() {
    _hideBottomTabBar.changeVisibility(false);
    notifyListeners();
  }

  void showBottomTab() {
    _hideBottomTabBar.changeVisibility(true);
    notifyListeners();
  }

  Future<void> refresh() async {
    await trailService.refreshTrails();
  }

  void _updateTrailScrollState() {
    if (!_homeModel.profileScrollController.hasClients) return;
    if (trailService.isLoadingTrails) return;
    if (!hasMoreTrails) return;

    double maxScrollExtent = _homeModel.profileScrollController.position.maxScrollExtent;
    double currentScroll = _homeModel.profileScrollController.position.pixels;
    double displayableHeight = _homeModel.profileScrollController.position.viewportDimension;
    
    double pixelsLeftToScroll = maxScrollExtent - currentScroll;
    double threshold = displayableHeight;
    bool shouldLoadMore = pixelsLeftToScroll <= threshold;

    if (shouldLoadMore) {
      loadMoreTrails();
    }
  }

  void loadMoreTrails() {
    if (trailService.isLoadingTrails || !hasMoreTrails) return;

    trailService.loadNextTrailPage().catchError((e) {
      _log.warning('Failed to load more trails: $e');
    });
  }

  bool get isLoadingMoreTrails => trailService.isLoadingTrails;

  bool get isInitialLoadingTrails => trailService.isInitialLoad;

  bool get hasMoreTrails => trailService.hasMoreTrails;

  bool get hasPaginationError => 
      trailService.trailsResponse.result == false;

  String? get paginationError => 
      hasPaginationError ? trailService.trailsResponse.responseBody : null;

  void retryPagination() {
    trailService.loadTrailPage().catchError((e) {
      _log.warning('Failed to retry pagination: $e');
    });
  }

  @override
  void dispose() {
    _homeModel.profileScrollController.removeListener(_updateTrailScrollState);
    _loadingStateListener.cancel();
    super.dispose();
  }
}

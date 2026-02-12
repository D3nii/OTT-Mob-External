import 'package:http/http.dart' as http;
import 'package:onetwotrail/config/config.dart';
import 'package:onetwotrail/repositories/services/api_one_two_trail.dart';
import 'package:onetwotrail/repositories/services/api_one_two_trail_filter.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/services/base_view_service.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/repositories/services/filter_service.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/search_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/utils/hide_bottom_tabBar.dart';
import 'package:onetwotrail/v2/event/event_client.dart';
import 'package:onetwotrail/v2/event/event_serializer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Components {
  static final Components _components = Components();

  static Components getInstance() {
    return _components;
  }

  late Config config;
  late SharedPreferences sharedPreferences;

  // Application API
  late ApplicationApi applicationApi;

  // Proxies
  late ApiProxy apiProxy;
  late FilterApiProxy filterApiProxy;

  // Services
  late AuthenticationService authenticationService;
  late BaseViewService baseViewService;
  late DiscoveryService discoveryService;
  late FilterService filterService;
  late ProfileService profileService;
  late SearchService searchService;
  late TrailService trailService;

  // Models
  late HideBottomTabBar hideBottomTabBar;

  // Events
  late EventClient eventClient;

  static Future<void> initialize(Config config) async {
    // Configuration
    _components.config = config;

    // Shared Preferences
    _components.sharedPreferences = await SharedPreferences.getInstance();
    // Application API
    _components.applicationApi = new ApplicationApi.initialize(config, _components.sharedPreferences);
    // Proxies
    _components.apiProxy = new ApiProxy(_components.applicationApi);
    _components.filterApiProxy = new FilterApiProxy(_components.applicationApi);
    // Services
    _components.authenticationService = new AuthenticationService(_components.applicationApi, _components.apiProxy);
    _components.baseViewService = new BaseViewService();
    _components.discoveryService = new DiscoveryService(_components.applicationApi);
    _components.filterService = new FilterService(_components.filterApiProxy);
    _components.profileService = new ProfileService(_components.applicationApi);
    _components.searchService = new SearchService(_components.applicationApi, _components.sharedPreferences);
    _components.trailService = new TrailService(_components.applicationApi);
    // Models
    _components.hideBottomTabBar = new HideBottomTabBar();
    // Events
    _components.eventClient = new EventClient(
      config.apiUrl,
      new EventSerializer(),
      new http.Client(),
    );
  }

  static Future<void> restart() async {
    await initialize(_components.config);
  }
}

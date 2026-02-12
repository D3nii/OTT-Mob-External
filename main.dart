import 'package:flavor/flavor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/components.dart';
import 'package:onetwotrail/config/config.dart';
import 'package:onetwotrail/flavor.dart';
import 'package:onetwotrail/repositories/models/home_component_visibility_status.dart';
import 'package:onetwotrail/repositories/models/user.dart';
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
import 'package:onetwotrail/restart.dart';
import 'package:onetwotrail/services/crash_reporter.dart';
import 'package:onetwotrail/ui/app_router.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/utils/app_environment.dart';
import 'package:onetwotrail/utils/base_view_provider.dart';
import 'package:onetwotrail/utils/hide_bottom_tabBar.dart';
import 'package:onetwotrail/v2/event/event_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = Logger('main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();
  final config = await setupConfig();
  setupEnvironment(config);
  setupFlavor(config);
  await setupCrashReporting(config);
  await setupComponents(config);
  setupApp();
}

Future<Config> setupConfig() async {
  return await Config.readFromEnvironment();
}

void setupEnvironment(Config config) {
  AppEnvironment.initialize(config);
}

Future<void> setupCrashReporting(Config config) async {
  try {
    await CrashReporter.initialize(config);
  } catch (error, stackTrace) {
    _logger.severe('Failed to initialize crash reporting', error, stackTrace);
  }
}

Future<void> setupComponents(Config config) async {
  await Components.initialize(config);
}

void setupApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(App());
}

void setupLogging() {
  var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  recordStackTraceAtLevel = Level.WARNING;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${dateFormat.format(record.time)} ${record.level.name} ${record.loggerName}: ${record.message}');
    if (record.stackTrace != null) {
      print('${record.stackTrace}');
    }
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Prevent the soft keyboard from showing on app start
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    return FlavorBanner(child: RestartWidget(child: buildMultiProvider(context)));
  }

  MultiProvider buildMultiProvider(BuildContext context) {
    var components = Components.getInstance();
    return MultiProvider(providers: [
      // Config
      Provider<Config>(create: (context) => components.config),
      // Shared Preferences
      Provider<SharedPreferences>(create: (context) => components.sharedPreferences),
      // Application API
      Provider<ApplicationApi>(create: (context) => components.applicationApi),
      // Proxies
      Provider<ApiProxy>(create: (context) => components.apiProxy),
      Provider<FilterApiProxy>(create: (context) => components.filterApiProxy),
      // Services
      Provider<AuthenticationService>(create: (context) => components.authenticationService),
      Provider<BaseViewService>(create: (context) => components.baseViewService),
      Provider<DiscoveryService>(create: (context) => components.discoveryService),
      Provider<FilterService>(create: (context) => components.filterService),
      Provider<ProfileService>(create: (context) => components.profileService),
      Provider<SearchService>(create: (context) => components.searchService),
      Provider<TrailService>(create: (context) => components.trailService),
      // Models
      Provider<HideBottomTabBar>(create: (context) => components.hideBottomTabBar),
      StreamProvider<HomeComponentVisibilityStatus>(
        initialData: components.hideBottomTabBar.status,
        create: (context) => components.hideBottomTabBar.hideBottomTabBar,
      ),
      StreamProvider<BaseView>(
        initialData: BaseView(),
        create: (context) => components.baseViewService.baseView,
      ),
      StreamProvider<User>(
        initialData: components.profileService.user,
        create: (context) => components.profileService.userStream,
      ),
      // Events
      Provider<EventClient>(create: (context) => components.eventClient),
    ], child: buildMaterialApp(context));
  }

  MaterialApp buildMaterialApp(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Poppins',
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: tealish),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(surface: Colors.white),
        ),
        supportedLocales: [
          Locale("en"),
        ],
        title: 'One Two Trail',
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRouter,
        onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}')))));
  }
}

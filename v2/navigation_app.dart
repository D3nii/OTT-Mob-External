import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class WazeNavigationApp extends NavigationApp {
  WazeNavigationApp()
      : _logger = Logger('WazeNavigationApp'),
        super(
          name: 'Waze',
        );

  final Logger _logger;

  @override
  Future<bool> launchLocation(double latitude, double longitude) async {
    _logger.info('Launching Waze with coordinates: $latitude, $longitude');

    try {
      // Use the exact coordinates as provided - don't modify precision
      _logger.info('Using exact coordinates: $latitude, $longitude');

      // Use only the web URL format for simplicity and reliability
      Uri webUri = Uri.parse('https://waze.com/ul?ll=$latitude,$longitude&navigate=yes');
      _logger.info('Using web URI: ${webUri.toString()}');

      // Launch with external application mode to ensure it opens in the Waze app if installed
      _logger.info('Launching with external application mode');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      _logger.info('Successfully launched Waze via web URL');
      return true;
    } catch (e) {
      _logger.severe('Failed to launch Waze: $e');
      return false;
    }
  }
}

class GoogleMapsNavigationApp extends NavigationApp {
  GoogleMapsNavigationApp()
      : _logger = Logger('GoogleMapsNavigationApp'),
        super(
          name: 'Google Maps',
        );

  final Logger _logger;

  @override
  Future<bool> launchLocation(double latitude, double longitude) async {
    _logger.info('Launching Google Maps with coordinates: $latitude, $longitude');

    try {
      // Use the exact coordinates as provided - don't modify precision
      _logger.info('Using exact coordinates: $latitude, $longitude');

      // Use only the web URL format for simplicity and reliability
      Uri webUri = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '$latitude,$longitude',
      });
      _logger.info('Using web URI: ${webUri.toString()}');

      // Launch with external application mode to ensure it opens in the Google Maps app if installed
      _logger.info('Launching with external application mode');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      _logger.info('Successfully launched Google Maps via web URL');
      return true;
    } catch (e) {
      _logger.severe('Failed to launch Google Maps: $e');
      return false;
    }
  }
}

class NavigationApps {
  static final List<NavigationApp> _apps = [
    WazeNavigationApp(),
    GoogleMapsNavigationApp(),
  ];

  static List<NavigationApp> asList() {
    return _apps;
  }
}

class NavigationApp {
  final String name;

  NavigationApp({required this.name});

  /// Launches the navigation app with the given coordinates
  /// Returns true if the app was launched successfully, false otherwise
  Future<bool> launchLocation(double latitude, double longitude) async {
    return false; // Base implementation returns false
  }
}

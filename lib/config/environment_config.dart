class _EnvironmentConfig {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const String datadogApplicationId = String.fromEnvironment('DATADOG_APPLICATION_ID');
  static const String datadogClientToken = String.fromEnvironment('DATADOG_CLIENT_TOKEN');
  static const String datadogServiceName = String.fromEnvironment('DATADOG_SERVICE_NAME');
  static const String flavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}

class EnvironmentConfig {
  String get apiUrl => _EnvironmentConfig.apiUrl;
  String get datadogApplicationId => _EnvironmentConfig.datadogApplicationId;
  String get datadogClientToken => _EnvironmentConfig.datadogClientToken;
  String get datadogServiceName => _EnvironmentConfig.datadogServiceName;
  String get flavor => _EnvironmentConfig.flavor;
  String get googleMapsApiKey => _EnvironmentConfig.googleMapsApiKey;
}

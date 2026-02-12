import 'config.dart';

class ConfigValidator {
  Future<void> validate(Config config) async {
    _validateApiUrl(config.apiUrl);
    _validateDatadogApplicationId(config.datadogApplicationId);
    _validateDatadogClientToken(config.datadogClientToken);
    _validateGoogleMapsApiKey(config.googleMapsApiKey);
    _validateFlavor(config.flavor);
    await _validateDatadogVersion(config.datadogVersion);
  }

  static void _validateApiUrl(String apiUrl) {
    if (apiUrl.isEmpty) {
      throw ArgumentError('apiUrl must be set.');
    }
  }

  static void _validateDatadogApplicationId(String datadogApplicationId) {
    if (datadogApplicationId.isEmpty) {
      throw ArgumentError('datadogApplicationId must be set.');
    }
  }

  static void _validateDatadogClientToken(String datadogClientToken) {
    if (datadogClientToken.isEmpty) {
      throw ArgumentError('datadogClientToken must be set.');
    }
  }

  static void _validateGoogleMapsApiKey(String googleMapsApiKey) {
    if (googleMapsApiKey.isEmpty) {
      throw ArgumentError('googleMapsApiKey must be set.');
    }
  }

  static void _validateFlavor(String flavor) {
    if (flavor.isEmpty) {
      throw ArgumentError('flavor must be set.');
    }
  }

  static Future<void> _validateDatadogVersion(String version) async {
    if (version.isEmpty) {
      throw Exception('datadogVersion must be set.');
    }
  }
}

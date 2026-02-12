import 'dart:io';

import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'config.dart';
import 'config_reader.dart';
import 'environment_config.dart';

class EnvironmentConfigReader implements ConfigReader {
  static final Logger _logger = Logger('EnvironmentConfigReader');
  final EnvironmentConfig _environmentConfig;

  EnvironmentConfigReader({EnvironmentConfig? environmentConfig})
      : _environmentConfig = environmentConfig ?? EnvironmentConfig();

  @override
  Future<Config> read() async {
    final apiUrl = _readApiUrl();
    final datadogVersion = await _readVersion();

    final config = Config(
      apiUrl: apiUrl,
      datadogApplicationId: _environmentConfig.datadogApplicationId,
      datadogClientToken: _environmentConfig.datadogClientToken,
      datadogEnvironment: _environmentConfig.flavor,
      datadogServiceName: _environmentConfig.datadogServiceName,
      datadogVersion: datadogVersion,
      flavor: _environmentConfig.flavor,
      googleMapsApiKey: _environmentConfig.googleMapsApiKey,
    );

    return config;
  }

  String _readApiUrl() {
    final apiUrl = _environmentConfig.apiUrl ?? 'https://api.onetwotrail.com';
    final flavor = _environmentConfig.flavor;

    try {
      if (flavor == 'development' && Platform.isAndroid) {
        return _replaceLocalhostForAndroidEmulator(apiUrl);
      }
    } catch (e) {
      // Platform detection not available (e.g., on web), use original URL
    }
    return apiUrl;
  }

  String _replaceLocalhostForAndroidEmulator(String url) {
    return url.replaceFirst(
        RegExp(r'^(https?://)?localhost\b'),
        (match) {
          final protocol = match.group(1) ?? '';
          return '${protocol}10.0.2.2';
        } as String);
  }

  Future<String> _readVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      if (version.isEmpty) {
        throw Exception('Version from PackageInfo is empty');
      }
      return version;
    } catch (e, stackTrace) {
      _logger.severe('Failed to load app version dynamically', e, stackTrace);
      throw Exception('Failed to discover app version: $e');
    }
  }
}

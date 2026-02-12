import 'package:flutter_test/flutter_test.dart';
import 'package:onetwotrail/config/environment_config.dart';
import 'package:onetwotrail/config/environment_config_reader.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('EnvironmentConfigReader', () {
    group('read', () {
      test('should return config with all required fields populated', () async {
        _packageInfo();
        _environmentConfig();

        final reader = _reader();
        final config = await reader.read();

        expect(config.apiUrl, equals('https://api.test.com'));
        expect(config.datadogApplicationId, equals('test-app-id'));
        expect(config.datadogClientToken, equals('test-client-token'));
        expect(config.datadogEnvironment, equals('test'));
        expect(config.datadogServiceName, equals('test-service'));
        expect(config.datadogVersion, equals('1.0.0'));
        expect(config.flavor, equals('test'));
        expect(config.googleMapsApiKey, equals('test-maps-key'));
      });

      test('should return config with version from package info', () async {
        _packageInfo(version: '2.1.0');
        _environmentConfig();

        final reader = _reader();
        final config = await reader.read();

        expect(config.datadogVersion, equals('2.1.0'));
      });

      test('should throw exception when version is empty', () async {
        _packageInfo(version: '');
        _environmentConfig();

        final reader = _reader();

        await expectLater(
          reader.read(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Version from PackageInfo is empty'),
            ),
          ),
        );
      });

      group('with api url handling', () {
        group('with development flavor', () {
          test('should keep localhost unchanged when not on android platform', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'http://localhost:8080/api/v1',
              flavor: 'development',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('http://localhost:8080/api/v1'));
          });

          test('should keep api url unchanged when it does not contain localhost', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'https://dev.api.com/api',
              flavor: 'development',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('https://dev.api.com/api'));
          });

          test('should keep localhost in path unchanged when not on android', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'http://api.com/redirect/localhost:9090',
              flavor: 'development',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('http://api.com/redirect/localhost:9090'));
          });

          test('should keep localhost at beginning of path unchanged when not on android', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'localhost:3000/api',
              flavor: 'development',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('localhost:3000/api'));
          });

          test('should keep localhost with https protocol unchanged when not on android', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'https://localhost:443/secure/api',
              flavor: 'development',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('https://localhost:443/secure/api'));
          });

          test('should keep localhost in query params unchanged when not on android', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'https://api.com/search?redirect=localhost:8080',
              flavor: 'development',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('https://api.com/search?redirect=localhost:8080'));
          });
        });

        group('with staging flavor', () {
          test('should keep api url unchanged when flavor is staging', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'http://localhost:8080/api',
              flavor: 'staging',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('http://localhost:8080/api'));
          });
        });

        group('with production flavor', () {
          test('should keep api url unchanged when flavor is production', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'http://localhost:8080/api',
              flavor: 'production',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('http://localhost:8080/api'));
          });
        });

        group('with empty flavor', () {
          test('should keep api url unchanged when flavor is empty', () async {
            _packageInfo();
            final envConfig = _environmentConfig(
              apiUrl: 'http://localhost:8080/api',
              flavor: '',
            );

            final reader = _reader(environmentConfig: envConfig);
            final config = await reader.read();

            expect(config.apiUrl, equals('http://localhost:8080/api'));
          });
        });
      });
    });
  });
}

void _packageInfo({String version = '1.0.0'}) {
  PackageInfo.setMockInitialValues(
    appName: 'onetwotrail',
    packageName: 'com.onetwotrail.test',
    version: version,
    buildNumber: '1',
    buildSignature: '',
  );
}

_MockEnvironmentConfig _environmentConfig({
  String apiUrl = 'https://api.test.com',
  String datadogApplicationId = 'test-app-id',
  String datadogClientToken = 'test-client-token',
  String datadogServiceName = 'test-service',
  String flavor = 'test',
  String googleMapsApiKey = 'test-maps-key',
}) {
  return _MockEnvironmentConfig(
    apiUrl: apiUrl,
    datadogApplicationId: datadogApplicationId,
    datadogClientToken: datadogClientToken,
    datadogServiceName: datadogServiceName,
    flavor: flavor,
    googleMapsApiKey: googleMapsApiKey,
  );
}

EnvironmentConfigReader _reader({EnvironmentConfig? environmentConfig}) {
  return EnvironmentConfigReader(
    environmentConfig: environmentConfig ?? _environmentConfig(),
  );
}

class _MockEnvironmentConfig extends EnvironmentConfig {
  final String _apiUrl;
  final String _datadogApplicationId;
  final String _datadogClientToken;
  final String _datadogServiceName;
  final String _flavor;
  final String _googleMapsApiKey;

  _MockEnvironmentConfig({
    required String apiUrl,
    required String datadogApplicationId,
    required String datadogClientToken,
    required String datadogServiceName,
    required String flavor,
    required String googleMapsApiKey,
  })  : _apiUrl = apiUrl,
        _datadogApplicationId = datadogApplicationId,
        _datadogClientToken = datadogClientToken,
        _datadogServiceName = datadogServiceName,
        _flavor = flavor,
        _googleMapsApiKey = googleMapsApiKey;

  @override
  String get apiUrl => _apiUrl;

  @override
  String get datadogApplicationId => _datadogApplicationId;

  @override
  String get datadogClientToken => _datadogClientToken;

  @override
  String get datadogServiceName => _datadogServiceName;

  @override
  String get flavor => _flavor;

  @override
  String get googleMapsApiKey => _googleMapsApiKey;
}

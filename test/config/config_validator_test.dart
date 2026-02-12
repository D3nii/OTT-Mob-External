import 'package:flutter_test/flutter_test.dart';
import 'package:onetwotrail/config/config.dart';
import 'package:onetwotrail/config/config_validator.dart';

void main() {
  group('ConfigValidator', () {
    group('validate', () {
      test('should complete successfully with valid configuration', () async {
        final validator = ConfigValidator();
        final config = _config();

        await expectLater(
          validator.validate(config),
          completes,
        );
      });

      group('with invalid api url', () {
        test('should throw argument error when api url is empty', () async {
          final validator = ConfigValidator();
          final config = _config(apiUrl: '');

          await expectLater(
            validator.validate(config),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'apiUrl must be set.',
              ),
            ),
          );
        });
      });

      group('with invalid datadog application id', () {
        test('should throw argument error when datadog application id is empty', () async {
          final validator = ConfigValidator();
          final config = _config(datadogApplicationId: '');

          await expectLater(
            validator.validate(config),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'datadogApplicationId must be set.',
              ),
            ),
          );
        });
      });

      group('with invalid datadog client token', () {
        test('should throw argument error when datadog client token is empty', () async {
          final validator = ConfigValidator();
          final config = _config(datadogClientToken: '');

          await expectLater(
            validator.validate(config),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'datadogClientToken must be set.',
              ),
            ),
          );
        });
      });

      group('with invalid google maps api key', () {
        test('should throw argument error when google maps api key is empty', () async {
          final validator = ConfigValidator();
          final config = _config(googleMapsApiKey: '');

          await expectLater(
            validator.validate(config),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'googleMapsApiKey must be set.',
              ),
            ),
          );
        });
      });

      group('with invalid flavor', () {
        test('should throw argument error when flavor is empty', () async {
          final validator = ConfigValidator();
          final config = _config(flavor: '');

          await expectLater(
            validator.validate(config),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'flavor must be set.',
              ),
            ),
          );
        });
      });

      group('with invalid datadog version', () {
        test('should throw exception when datadog version is empty', () async {
          final validator = ConfigValidator();
          final config = _config(datadogVersion: '');

          await expectLater(
            validator.validate(config),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                'Exception: datadogVersion must be set.',
              ),
            ),
          );
        });
      });
    });
  });
}

Config _config({
  String? apiUrl,
  String? datadogApplicationId,
  String? datadogClientToken,
  String? datadogEnvironment,
  String? datadogServiceName,
  String? datadogVersion,
  String? flavor,
  String? googleMapsApiKey,
}) {
  return Config(
    apiUrl: apiUrl ?? 'https://api.example.com',
    datadogApplicationId: datadogApplicationId ?? 'test-app-id',
    datadogClientToken: datadogClientToken ?? 'test-client-token',
    datadogEnvironment: datadogEnvironment ?? 'test',
    datadogServiceName: datadogServiceName ?? 'test-service',
    datadogVersion: datadogVersion ?? '1.0.0',
    flavor: flavor ?? 'test',
    googleMapsApiKey: googleMapsApiKey ?? 'test-maps-key',
  );
}

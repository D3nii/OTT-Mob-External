import 'package:flavor/flavor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetwotrail/config/config.dart';
import 'package:onetwotrail/flavor.dart';

Config _config({required String flavor}) {
  return Config(
    apiUrl: 'https://api.test.com',
    datadogApplicationId: 'test-app-id',
    datadogClientToken: 'test-client-token',
    datadogEnvironment: 'test',
    datadogServiceName: 'test-service',
    datadogVersion: '1.0.0',
    flavor: flavor,
    googleMapsApiKey: 'test-maps-key',
  );
}

void main() {
  group('setupFlavor', () {
    group('with development flavor', () {
      test('creates development flavor', () {
        final config = _config(flavor: 'development');

        setupFlavor(config);

        expect(Flavor.I.environment, Environment.dev);
        expect(Flavor.I.isDevelopment, true);
        expect(Flavor.I.title, 'development');
      });
    });

    group('with staging flavor', () {
      test('creates staging flavor', () {
        final config = _config(flavor: 'staging');

        setupFlavor(config);

        expect(Flavor.I.environment, Environment.beta);
        expect(Flavor.I.isBeta, true);
        expect(Flavor.I.title, 'staging');
      });
    });

    group('with production flavor', () {
      test('creates production flavor', () {
        final config = _config(flavor: 'production');

        setupFlavor(config);

        expect(Flavor.I.environment, Environment.production);
        expect(Flavor.I.isProduction, true);
        expect(Flavor.I.title, 'production');
      });
    });

    group('with empty flavor', () {
      test('throws error', () {
        final config = _config(flavor: '');

        expect(() => setupFlavor(config), throwsA(anything));
      });
    });

    group('with unknown flavor value', () {
      test('throws error', () {
        final config = _config(flavor: 'unknown');

        expect(() => setupFlavor(config), throwsA(anything));
      });
    });
  });
}

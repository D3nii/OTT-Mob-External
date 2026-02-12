import 'dart:ui';

import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/config/config.dart';

class CrashReporter {
  static final Logger _logger = Logger('CrashReporter');

  static FlutterExceptionHandler? _originalFlutterErrorHandler;
  static ErrorCallback? _originalPlatformErrorHandler;

  static Future<void> initialize(Config config) async {
    _logger.info('Initializing crash reporter');

    try {
      await _initializeDatadog(config);
      _setupFlutterErrorHandler();
      _setupPlatformErrorHandler();
    } catch (error, stackTrace) {
      _logger.severe('Failed to initialize crash reporter', error, stackTrace);
      rethrow;
    }
  }

  static Future<void> _initializeDatadog(Config config) async {
    final datadogConfiguration = DatadogConfiguration(
      clientToken: config.datadogClientToken,
      env: config.datadogEnvironment,
      site: DatadogSite.us5,
      service: config.datadogServiceName,
      version: config.datadogVersion,
      nativeCrashReportEnabled: true,
      rumConfiguration: DatadogRumConfiguration(
        applicationId: config.datadogApplicationId,
      ),
    );

    await DatadogSdk.instance.initialize(
      datadogConfiguration,
      TrackingConsent.granted,
    );
  }

  static void _setupFlutterErrorHandler() {
    _originalFlutterErrorHandler = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.severe('Reporting Flutter error', details.exception, details.stack);

      try {
        DatadogSdk.instance.rum?.addErrorInfo(
          details.exception.toString(),
          RumErrorSource.source,
          stackTrace: details.stack,
          errorType: details.exception.runtimeType.toString(),
          attributes: {'flutter_error_reason': details.context?.toString()},
        );
      } catch (error) {
        _logger.warning('Failed to report Flutter error to Datadog: $error');
      }

      _originalFlutterErrorHandler?.call(details);
    };
  }

  static void _setupPlatformErrorHandler() {
    _originalPlatformErrorHandler = PlatformDispatcher.instance.onError;

    PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
      _logger.severe('Reporting platform error', error, stackTrace);

      try {
        DatadogSdk.instance.rum?.addErrorInfo(
          error.toString(),
          RumErrorSource.source,
          stackTrace: stackTrace,
          errorType: error.runtimeType.toString(),
        );
      } catch (reportingError) {
        _logger.warning('Failed to report platform error to Datadog: $reportingError');
      }

      return _originalPlatformErrorHandler?.call(error, stackTrace) ?? false;
    };
  }

  static void reportError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, Object?>? attributes,
  }) {
    _logger.severe('Reporting error', error, stackTrace);

    try {
      final errorMessage = context != null ? '$context: $error' : error.toString();

      DatadogSdk.instance.rum?.addErrorInfo(
        errorMessage,
        RumErrorSource.source,
        stackTrace: stackTrace,
        attributes: attributes ?? {},
        errorType: error.runtimeType.toString(),
      );
    } catch (reportingError) {
      _logger.warning('Failed to report error to Datadog: $reportingError');
    }
  }
}

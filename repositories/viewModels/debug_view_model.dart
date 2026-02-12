import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/services/crash_reporter.dart';

class DebugViewModel extends ChangeNotifier {
  static final Logger _logger = Logger('DebugViewModel');

  /// Triggers a Flutter framework error by causing a widget build error
  void triggerFlutterError() {
    _logger.info('Triggering Flutter framework error');

    // This will cause a Flutter framework error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      throw FlutterError('Test Flutter Error');
    });
  }

  /// Triggers a Dart runtime error
  void triggerRuntimeError() {
    _logger.info('Triggering Dart runtime error');

    // This will cause a null pointer exception
    String? nullString;
    nullString!.length; // This will throw
  }

  /// Triggers a manual error report with context and attributes
  void triggerManualError() {
    _logger.info('Triggering manual error report');

    final error = Exception('Test Manual Error');
    final stackTrace = StackTrace.current;

    CrashReporter.reportError(
      error,
      stackTrace,
      context: 'Test Manual Error',
      attributes: {
        'test_type': 'manual_error',
        'timestamp': DateTime.now().toIso8601String(),
        'user_action': 'debug_test',
        'error_severity': 'test',
        'test_id': _generateTestId(),
      },
    );
  }

  /// Generates a unique test ID for tracking
  String _generateTestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'test_${timestamp}_$random';
  }
}

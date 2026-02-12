import 'package:onetwotrail/config/config.dart';

/// Utility class for environment-related operations and checks.
class AppEnvironment {
  final String _environment;

  /// Private constructor that takes the environment string.
  AppEnvironment._(this._environment);

  /// Static instance of AppEnvironment.
  static AppEnvironment? _instance;

  /// Factory method to create AppEnvironment instance from Config.
  static AppEnvironment initialize(Config config) {
    _instance = AppEnvironment._(config.datadogEnvironment);
    return _instance!;
  }

  /// Gets the current AppEnvironment instance.
  ///
  /// Throws [StateError] if AppEnvironment has not been initialized.
  static AppEnvironment get instance {
    if (_instance == null) {
      throw StateError('AppEnvironment not initialized. Call AppEnvironment.initialize() first.');
    }
    return _instance!;
  }

  /// Checks if the current environment allows debug functionality.
  ///
  /// Returns `true` if the current environment is development or staging,
  /// `false` otherwise (e.g., production).
  static bool isDebugEnvironment() {
    return instance._environment == 'development' || instance._environment == 'staging';
  }

  /// Gets the current environment name.
  ///
  /// Returns the current environment string.
  static String getCurrentEnvironment() {
    return instance._environment;
  }

  /// Checks if the current environment is production.
  ///
  /// Returns `true` if the current environment is production,
  /// `false` otherwise.
  static bool isProduction() {
    return instance._environment == 'production';
  }

  /// Checks if the current environment is staging.
  ///
  /// Returns `true` if the current environment is staging,
  /// `false` otherwise.
  static bool isStaging() {
    return instance._environment == 'staging';
  }

  /// Checks if the current environment is development.
  ///
  /// Returns `true` if the current environment is development,
  /// `false` otherwise.
  static bool isDevelopment() {
    return instance._environment == 'development';
  }
}

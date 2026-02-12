import 'config_reader.dart';
import 'config_validator.dart';
import 'environment_config_reader.dart';

class Config {
  final String apiUrl;
  final String datadogApplicationId;
  final String datadogClientToken;
  final String datadogEnvironment;
  final String datadogServiceName;
  final String datadogVersion;
  final String flavor;
  final String googleMapsApiKey;

  const Config({
    required this.apiUrl,
    required this.datadogApplicationId,
    required this.datadogClientToken,
    required this.datadogEnvironment,
    required this.datadogServiceName,
    required this.datadogVersion,
    required this.flavor,
    required this.googleMapsApiKey,
  });

  static Future<Config> readFromEnvironment() async {
    final reader = EnvironmentConfigReader();
    final validator = ConfigValidator();
    return await _readConfig(reader, validator);
  }

  static Future<Config> _readConfig(ConfigReader reader, ConfigValidator validator) async {
    final config = await reader.read();
    await validator.validate(config);
    return config;
  }
}

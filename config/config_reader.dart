import 'config.dart';

abstract class ConfigReader {
  Future<Config> read();
}

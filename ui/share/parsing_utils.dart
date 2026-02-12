class ParsingHelpers {
  static double doubleValue(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value.toDouble;
    }
  }
}

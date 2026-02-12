/// Converts a list of dynamic values to a list of strings, throwing on invalid entries
///
/// Returns null if the input list is null
List<String>? fromDynamicListToStringList(List<dynamic>? values) {
  if (values == null) return null;

  List<String> strings = [];
  for (var value in values) {
    if (value is String) {
      strings.add(value);
      continue;
    }
    throw Exception('Invalid string list');
  }
  return strings;
}

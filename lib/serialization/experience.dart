import 'package:onetwotrail/repositories/models/experience.dart';

/// Converts a list of dynamic maps to a list of Experience objects, throwing on invalid entries
///
/// Returns null if the input list is null
List<Experience>? fromDynamicMapListToExperienceList(List<dynamic>? values) {
  if (values == null) return null;

  List<Experience> experiences = [];
  for (var value in values) {
    if (value is Map<String, dynamic>) {
      experiences.add(Experience.fromJson(value));
      continue;
    }
    throw Exception('Invalid experience');
  }
  return experiences;
}

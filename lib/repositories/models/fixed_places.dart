import 'package:onetwotrail/repositories/models/experience.dart';

class FixedPlaces {
  List<Experience> fixedPlaces;

  FixedPlaces.init() : fixedPlaces = [];

  FixedPlaces({required this.fixedPlaces});

  factory FixedPlaces.fromJson(Map<String, dynamic> json) {
    List<Experience> experiences = [];
    if (json['fixedPlaces'] != null) {
      for (var experienceMap in json['fixedPlaces'] as List) {
        Experience newExperience = Experience.fromJson(experienceMap as Map<String, dynamic>);
        experiences.add(newExperience);
      }
    }

    return FixedPlaces(fixedPlaces: experiences);
  }

  @override
  String toString() {
    return 'FixedPlaces{fixedPlaces: $fixedPlaces}';
  }
}

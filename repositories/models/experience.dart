import 'package:onetwotrail/serialization/experience.dart';
import 'package:onetwotrail/serialization/string.dart';
import 'package:onetwotrail/utils/date_time_utils.dart';

class Experience {
  int experienceId;
  int experienceInTrailId;

  DateTime visitEndTime;
  DateTime visitStartTime;

  Duration stayTime;

  List<Experience> nearBy;
  List<Experience> related;

  List<String> imageUrls;
  List<String> paymentMethods;
  List<String> topics;

  String description;
  String destinationName;
  String draftId;
  String email;
  String facebook;
  String instagram;
  String name;
  String phone;
  String recommendations;
  String title;
  String visitTime = '';
  String website;
  String whatsApp;

  bool accommodation;
  bool active;
  bool adultsOnly;
  bool allTerrainVehicleOnly;
  bool approved;
  bool birdWatching;
  bool camping;
  bool carbonNeutral;
  bool evCharger;
  bool foodDrinks;
  bool isVisitEvent = false;
  bool internet;
  bool parking;
  bool petFriendly;
  bool publicTransport;
  bool securityLockers;
  bool showers;
  bool smokingArea;
  bool toilets;
  bool visited;
  bool wheelchairAccessible;

  double latitude;
  double longitude;

  int likes;

  // These fields are already declared above, so we don't need to redeclare them

  Experience({
    required this.experienceId,
    required this.experienceInTrailId,
    required this.accommodation,
    required this.active,
    required this.adultsOnly,
    required this.allTerrainVehicleOnly,
    required this.approved,
    required this.birdWatching,
    required this.camping,
    required this.carbonNeutral,
    required this.description,
    required this.destinationName,
    required this.draftId,
    required this.email,
    required this.evCharger,
    required this.facebook,
    required this.foodDrinks,
    required this.imageUrls,
    required this.instagram,
    required this.internet,
    required this.latitude,
    required this.likes,
    required this.longitude,
    required this.name,
    required this.nearBy,
    required this.parking,
    required this.paymentMethods,
    required this.petFriendly,
    required this.phone,
    required this.publicTransport,
    required this.recommendations,
    required this.related,
    required this.securityLockers,
    required this.showers,
    required this.smokingArea,
    required this.stayTime,
    required this.title,
    required this.toilets,
    required this.topics,
    required this.visitEndTime,
    required this.visitStartTime,
    required this.visited,
    required this.website,
    required this.whatsApp,
    required this.wheelchairAccessible,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      experienceId: _fromDynamicMapToExperienceId(json),
      experienceInTrailId: json['experience_in_trail_id'] ?? 0,
      // DateTime
      visitEndTime: DateTimeUtils.parseDateTimeNullable(json['end_time']) ?? DateTime.now(),
      visitStartTime: DateTimeUtils.parseDateTimeNullable(json['start_time']) ?? DateTime.now(),
      // Duration
      stayTime: json['stay_in_minutes'] != null ? DateTimeUtils.fromMinutesToDuration(json['stay_in_minutes']) : Duration.zero,
      // List<Experience>
      nearBy: fromDynamicMapListToExperienceList(json['nearby_ids']) ?? [],
      related: fromDynamicMapListToExperienceList(json['related_ids']) ?? [],
      // List<String>
      imageUrls: _fromDynamicListToImageUrlList(json['images'] as List<dynamic>?),
      paymentMethods: fromDynamicListToStringList(json['payment_methods']) ?? [],
      topics: fromDynamicListToStringList(json['topics']) ?? [],
      // String
      destinationName: _fromDynamicMapToDestinationName(json),
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      recommendations: json['recommendations'] ?? '',
      title: json['title'] ?? '',
      website: json['website'] ?? '',
      whatsApp: json['whats_app'] ?? '',
      // Booleans
      accommodation: json['accommodation'] ?? false,
      active: json['active'] ?? false,
      adultsOnly: json['adults_only'] ?? false,
      allTerrainVehicleOnly: json['all_terrain_vehicle_only'] ?? false,
      approved: json['approved'] ?? false,
      birdWatching: json['bird_watching'] ?? false,
      camping: json['camping'] ?? false,
      carbonNeutral: json['carbon_neutral'] ?? false,
      description: json['description'] ?? '',
      draftId: json['draftId'] ?? '',
      email: json['email'] ?? '',
      evCharger: json['ev_charger'] ?? false,
      foodDrinks: json['food_drinks'] ?? false,
      internet: json['internet'] ?? false,
      parking: json['parking'] ?? false,
      petFriendly: json['pet_friendly'] ?? false,
      publicTransport: json['public_transport'] ?? false,
      securityLockers: json['security_lockers'] ?? false,
      showers: json['showers'] ?? false,
      smokingArea: json['smoking_area'] ?? false,
      toilets: json['toilets'] ?? false,
      visited: json['visited'] ?? false,
      wheelchairAccessible: json['wheelchair_accessible'] ?? false,
      // Doubles
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      // Integers
      likes: json['likes'] ?? 0,
    );
  }
}

String _fromDynamicMapToDestinationName(Map<String, dynamic> json) {
  if (json['destination'] is Map<String, dynamic>) {
    return json['destination']['name'] ?? '';
  }
  if (json['destination'] is String) {
    return json['destination'];
  }
  return '';
}

List<String> _fromDynamicListToImageUrlList(List<dynamic>? values) {
  if (values == null) return [];

  List<String> imageUrls = [];
  for (var value in values) {
    if (value is String) {
      imageUrls.add(value);
      continue;
    }
    if (value is Map<String, dynamic>) {
      final url = value['picture_url'];
      if (url != null) imageUrls.add(url);
      continue;
    }
    throw Exception('Invalid image url'); // Maintain original behavior of throwing
  }
  return imageUrls;
}

// Using DateTimeUtils instead of these local functions

int _fromDynamicMapToExperienceId(Map<String, dynamic> json) {
  return json['id'] ?? json['experience_id'] ?? 0;
}

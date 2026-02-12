import 'package:onetwotrail/repositories/enums/trail_status.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';

Trail trailFixture({
  int id = 1,
  String author = 'author',
  List<String> collaborators = const [],
  String description = 'desc',
  List<Experience> experiences = const <Experience>[],
  Duration itineraryEstimatedTime = Duration.zero,
  int itineraryId = 10,
  double latitude = 0.0,
  String listingDescription = '',
  int lockVersion = 0,
  double longitude = 0.0,
  String name = 'name',
  TrailStatus status = TrailStatus.OPEN,
  bool isPublic = false,
}) {
  return Trail(
    id: id,
    author: author,
    collaborators: collaborators,
    description: description,
    experiences: experiences,
    itineraryEstimatedTime: itineraryEstimatedTime,
    itineraryId: itineraryId,
    latitude: latitude,
    listingDescription: listingDescription,
    lockVersion: lockVersion,
    longitude: longitude,
    name: name,
    status: status,
    isPublic: isPublic,
  );
}

Map<String, dynamic> trailJsonFixture({
  int id = 1,
  String author = 'author',
  List<String> collaborators = const [],
  String description = 'desc',
  List<Map<String, dynamic>> experiences = const <Map<String, dynamic>>[],
  int itineraryEstimatedTimeInHours = 0,
  int itineraryId = 10,
  double latitude = 0.0,
  String listingDescription = '',
  int lockVersion = 0,
  double longitude = 0.0,
  String name = 'name',
  String status = 'OPEN',
  bool? isPublic,
}) {
  final json = <String, dynamic>{
    'id': id,
    'author': author,
    'collaborators': collaborators,
    'description': description,
    'experiences': experiences,
    'itinerary_estimated_time_in_hours': itineraryEstimatedTimeInHours,
    'itinerary_id': itineraryId,
    'latitude': latitude,
    'listing_description': listingDescription,
    'lock_version': lockVersion,
    'longitude': longitude,
    'name': name,
    'status': status,
  };
  if (isPublic != null) {
    json['is_public'] = isPublic;
  }
  return json;
}



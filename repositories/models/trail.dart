import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/repositories/enums/trail_status.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/serialization/experience.dart';
import 'package:onetwotrail/serialization/string.dart';
import 'package:onetwotrail/utils/date_time_utils.dart';
import 'package:onetwotrail/ui/share/geo_helpers.dart';

class Trail {
  int id;

  Duration itineraryEstimatedTime;

  List<Experience> experiences;
  List<String> collaborators;

  String author;
  String description;
  String listingDescription;
  String name;

  TrailStatus status;

  double latitude;
  double longitude;

  int itineraryId;
  int lockVersion;
  
  bool isPublic;

  LatLngBounds? _mapBounds;
  List<ImageProvider>? _imageProviders;

  Trail({
    required this.author,
    required this.collaborators,
    required this.description,
    required this.experiences,
    required this.id,
    required this.itineraryEstimatedTime,
    required this.itineraryId,
    required this.latitude,
    required this.listingDescription,
    required this.lockVersion,
    required this.longitude,
    required this.name,
    required this.status,
    this.isPublic = false,
  });

  List<ImageProvider> get imageProviders {
    if (_imageProviders != null) return _imageProviders!;

    _imageProviders = [];
    var imageUrls = <String>[];
    for (Experience value in experiences) {
      if (value.imageUrls.isNotEmpty) {
        imageUrls.add(value.imageUrls.first);
      }
    }
    for (String url in imageUrls) {
      _imageProviders!.add(NetworkImage(url));
    }
    // If the trail has less than 3 images, add a placeholder for each missing
    // image
    if (_imageProviders!.length < 3) {
      var emptyImage = AssetImage('assets/help/empty_image.png');
      var emptyImageCount = 3 - _imageProviders!.length;
      for (int i = 0; i < emptyImageCount; i++) {
        _imageProviders!.add(emptyImage);
      }
    }
    return _imageProviders!;
  }

  LatLngBounds get mapBounds {
    if (_mapBounds != null) return _mapBounds!;

    List<LatLng> experienceCoordinates = [];
    for (Experience experience in experiences) {
      experienceCoordinates.add(LatLng(experience.latitude, experience.longitude));
    }
    _mapBounds = GeoHelpers.getMapBoundsFromCoordinates(experienceCoordinates);
    return _mapBounds!;
  }

  factory Trail.fromJson(Map<String, dynamic> json) {
    return Trail(
      id: json['id'] ?? 0,
      experiences: fromDynamicMapListToExperienceList(json['experiences']) ?? [],
      collaborators: fromDynamicListToStringList(json['collaborators']) ?? [],
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      listingDescription: json['listing_description'] ?? '',
      lockVersion: json['lock_version'] ?? 0,
      name: json['name'] ?? '',
      status: _fromStringToTrailStatus(json['status']),
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      itineraryEstimatedTime: DateTimeUtils.fromHoursToDuration(json['itinerary_estimated_time_in_hours'] ?? 0),
      itineraryId: json['itinerary_id'] ?? 0,
      isPublic: (json['is_public'] as bool?) ?? false,
    );
  }
}

// Using DateTimeUtils instead of this local function

TrailStatus _fromStringToTrailStatus(String? value) {
  if (value == null) return TrailStatus.PAUSED;
  switch (value.toUpperCase()) {
    case 'OPEN':
      return TrailStatus.OPEN;
    case 'IN_PROGRESS':
      return TrailStatus.IN_PROGRESS;
    case 'PAUSED':
      return TrailStatus.PAUSED;
    case 'CANCELLED':
      return TrailStatus.CANCELLED;
    case 'CLOSED':
      return TrailStatus.CLOSED;
    case 'DONE':
      return TrailStatus.DONE;
    default:
      return TrailStatus.PAUSED;
  }
}

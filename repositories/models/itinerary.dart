import 'package:onetwotrail/repositories/models/itinerary_event.dart';
import 'package:onetwotrail/repositories/models/transit_itinerary_event.dart';
import 'package:onetwotrail/repositories/models/visit_itinerary_event.dart';

class Itinerary {
  int id;

  List<ItineraryEvent> events;

  String endDate;
  String startDate;

  int adultParticipantsCount;
  int endingExperienceId;
  int kidsParticipantsCount;
  int startingExperienceId;
  int teenParticipantsCount;
  int trailId;

  Itinerary({
    required this.id,
    required this.trailId,
    required this.adultParticipantsCount,
    required this.teenParticipantsCount,
    required this.kidsParticipantsCount,
    required this.startDate,
    required this.endDate,
    required this.startingExperienceId,
    required this.endingExperienceId,
    required this.events,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] ?? 0,
      trailId: json['trail_id'] ?? 0,
      adultParticipantsCount: json['adult_participants_count'] ?? 0,
      teenParticipantsCount: json['teen_participants_count'] ?? 0,
      kidsParticipantsCount: json['kids_participants_count'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startingExperienceId: json['starting_experience_id'] ?? 0,
      endingExperienceId: json['ending_experience_id'] ?? 0,
      events: _fromDynamicListToItineraryEventList(json['events']),
    );
  }
}

List<ItineraryEvent> _fromDynamicListToItineraryEventList(dynamic values) {
  if (values == null) {
    return [];
  }
  List<ItineraryEvent> events = [];
  (values as List).forEach((element) {
    ItineraryEvent? event;
    if (element['event_type'] == 'transit') {
      event = TransitItineraryEvent.fromJson(element);
    } else if (element['event_type'] == 'visit') {
      event = VisitItineraryEvent.fromJson(element);
    } else {
      // Skip invalid event types instead of throwing
      return;
    }
    events.add(event);
  });
  return events;
}

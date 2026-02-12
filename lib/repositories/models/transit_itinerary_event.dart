import 'package:onetwotrail/repositories/models/itinerary_event.dart';
import 'package:onetwotrail/utils/date_time_utils.dart';

class TransitItineraryEvent extends ItineraryEvent {
  String transportationType;
  int transitStartingExperienceId;
  int transitEndingExperienceId;

  TransitItineraryEvent({
    required int position,
    required DateTime startTime,
    required DateTime endTime,
    required this.transportationType,
    required this.transitStartingExperienceId,
    required this.transitEndingExperienceId,
  }) : super(position: position, startTime: startTime, endTime: endTime);

  factory TransitItineraryEvent.fromJson(Map<String, dynamic> json) {
    return TransitItineraryEvent(
      position: json['position'] ?? 0,
      startTime: DateTimeUtils.parseDateTime(json['start_time']),
      endTime: DateTimeUtils.parseDateTime(json['end_time']),
      transportationType: json['transportation_type'] ?? '',
      transitStartingExperienceId: json['transit_starting_experience_id'] ?? 0,
      transitEndingExperienceId: json['transit_ending_experience_id'] ?? 0,
    );
  }

  // Using DateTimeUtils instead of this local function
}

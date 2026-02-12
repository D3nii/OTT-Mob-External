import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/itinerary_event.dart';
import 'package:onetwotrail/utils/date_time_utils.dart';

class VisitItineraryEvent extends ItineraryEvent {
  Experience experience;

  VisitItineraryEvent({
    required int position,
    required DateTime startTime,
    required DateTime endTime,
    required this.experience,
  }) : super(position: position, startTime: startTime, endTime: endTime);

  factory VisitItineraryEvent.fromJson(Map<String, dynamic> json) {
    return VisitItineraryEvent(
      position: json['position'] ?? 0,
      startTime: DateTimeUtils.parseDateTime(json['start_time']),
      endTime: DateTimeUtils.parseDateTime(json['end_time']),
      experience: Experience.fromJson(json['experience'] as Map<String, dynamic>),
    );
  }

  // Using DateTimeUtils instead of this local function
}

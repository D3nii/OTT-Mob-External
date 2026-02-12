class ItineraryEvent {
  int position;
  DateTime startTime;
  DateTime endTime;
  Duration _duration = Duration.zero;

  Duration get duration {
    return _duration;
  }

  ItineraryEvent({
    required this.position,
    required this.startTime,
    required this.endTime,
  }) {
    _duration = endTime.difference(startTime);
  }
}

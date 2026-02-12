import 'dart:convert';

import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_tag.dart';

class EventSerializer {
  String serialize(Event event) {
    return jsonEncode({
      'name': event.name.name,
      'source_platform': event.sourcePlatform.name,
      'source_view': event.sourceView.name,
      'tags': _serializeTags(event.tags),
      'created_at': event.createdAt.toIso8601String(),
    });
  }

  static Map<String, String> _serializeTags(Map<EventTag, String> tags) {
    return tags.map((key, value) => MapEntry(key.name, value));
  }
}

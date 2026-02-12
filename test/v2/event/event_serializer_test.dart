import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_serializer.dart';

import 'event_factory.dart';

void main() {
  group("EventSerializer", () {
    late EventSerializer serializer;

    group("serialize", () {
      late Event event;

      group("with valid event", () {
        late String serialized;

        setUp(() {
          serializer = EventSerializer();
          event = mockEvent();
          serialized = serializer.serialize(event);
        });

        test("returns json", () {
          expect(
              serialized,
              jsonEncode({
                "name": "unknown",
                "source_platform": "unknown",
                "source_view": "unknown",
                "tags": {
                  "experience_id": "ExperienceId",
                  "topic_id": "TopicId",
                },
                "created_at": "2024-09-20T00:00:00.000",
              }));
        });
      });
    });
  });
}

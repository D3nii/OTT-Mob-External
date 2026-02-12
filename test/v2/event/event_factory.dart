import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_name.dart';
import 'package:onetwotrail/v2/event/event_source_platform.dart';
import 'package:onetwotrail/v2/event/event_source_view.dart';
import 'package:onetwotrail/v2/event/event_tag.dart';

class TestEvent extends Event {
  TestEvent({
    required EventName name,
    required EventSourcePlatform sourcePlatform,
    required EventSourceView sourceView,
    required Map<EventTag, String> tags,
    required DateTime createdAt,
  }) : super(
          name,
          sourceView,
          tags,
          sourcePlatform: sourcePlatform,
          createdAt: createdAt,
        );
}

Event mockEvent() {
  return TestEvent(
    name: EventName.unknown,
    sourcePlatform: EventSourcePlatform.unknown,
    sourceView: EventSourceView.unknown,
    tags: {
      EventTag.experience_id: "ExperienceId",
      EventTag.topic_id: "TopicId",
    },
    createdAt: DateTime.parse("2024-09-20"),
  );
}

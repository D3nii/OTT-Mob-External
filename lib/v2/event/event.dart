import 'dart:io';

import 'package:onetwotrail/v2/event/event_name.dart';
import 'package:onetwotrail/v2/event/event_source_platform.dart';
import 'package:onetwotrail/v2/event/event_source_view.dart';
import 'package:onetwotrail/v2/event/event_tag.dart';

class Event {
  final EventName name;
  final EventSourcePlatform sourcePlatform;
  final EventSourceView sourceView;
  final Map<EventTag, String> tags;
  final DateTime createdAt;

  Event(
    this.name,
    this.sourceView,
    this.tags, {
    EventSourcePlatform? sourcePlatform,
    DateTime? createdAt,
  })  : sourcePlatform = sourcePlatform ?? _getSourcePlatform(),
        createdAt = createdAt ?? DateTime.now();

  static _getSourcePlatform() {
    switch (Platform.operatingSystem) {
      case 'android':
        return EventSourcePlatform.android;
      case 'ios':
        return EventSourcePlatform.ios;
      default:
        throw Exception('Unsupported platform: ${Platform.operatingSystem}');
    }
  }
}

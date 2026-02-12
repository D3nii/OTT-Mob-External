import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_client.dart';
import 'package:onetwotrail/v2/event/event_serializer.dart';

import 'event_factory.dart';

class MockClient extends Mock implements Client {
  @override
  Future<Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return super.noSuchMethod(
      Invocation.method(#post, [url], {#headers: headers, #body: body, #encoding: encoding}),
      returnValue: Future.value(Response('', 200)),
    ) as Future<Response>;
  }
}

class MockEventSerializer extends Mock implements EventSerializer {
  String _serialized = 'serialized';

  @override
  String serialize(Event event) {
    return _serialized;
  }

  void setSerializedValue(String value) {
    _serialized = value;
  }
}
void main() {
  group('EventClient', () {
    String apiUrl = 'https://api.example.com/v1';
    late EventSerializer eventSerializer;
    late Client httpClient;
    late EventClient eventClient;

    setUp(() {
      eventSerializer = MockEventSerializer();
      // No need to use when() with our custom implementation

      httpClient = MockClient();
      when(httpClient.post(
        Uri.parse('https://api.example.com/v1/events'),
        headers: {'content-type': 'application/json'},
        body: 'serialized',
      )).thenAnswer((_) async => Response('', HttpStatus.accepted));

      eventClient = EventClient(
        apiUrl,
        eventSerializer,
        httpClient,
      );
    });

    group('createEvent', () {
      late Event event;

      setUp(() async {
        event = mockEvent();
      });

      group('with successful response', () {
        test('posts event to /v1/events', () async {
          await eventClient.createEvent(event);
          verify(
            httpClient.post(Uri.parse('https://api.example.com/v1/events'),
                headers: {
                  'content-type': 'application/json',
                },
                body: 'serialized'),
          ).called(1);
        });

        test('completes future', () async {
          await expectLater(eventClient.createEvent(event), completes);
        });
      });

      group('with error response', () {
        setUp(() {
          when(httpClient.post(
            Uri.parse('https://api.example.com/v1/events'),
            headers: {'content-type': 'application/json'},
            body: 'serialized',
          )).thenAnswer((_) async => Response('error', 500));
        });

        test('throws exception', () async {
          expect(() => eventClient.createEvent(event), throwsException);
        });
      });
    });
  });
}

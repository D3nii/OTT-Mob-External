import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_serializer.dart';

class EventClient {
  String _apiUrl;
  EventSerializer _eventSerializer;
  Client _httpClient;
  Logger _logger;

  EventClient(
    String apiUrl,
    EventSerializer eventSerializer,
    Client httpClient, {
    Logger? logger,
  })  : _apiUrl = apiUrl,
        _eventSerializer = eventSerializer,
        _httpClient = httpClient,
        _logger = logger ?? Logger((EventClient).toString());

  Future<void> createEvent(Event event) async {
    // log the name of the event
    _logger.info('creating event "${event.name.name}"');
    // encode event to json
    var json = _eventSerializer.serialize(event);
    // post json to /v1/events
    var response = await _post('/v1/events', json);
    // if the server responds with an error,
    // throw an exception with the error message
    if (response.statusCode != HttpStatus.accepted) {
      throw Exception('failed to create event: ${response.body}');
    }
  }

  Future<Response> _post(String path, String body) {
    return _httpClient.post(
      // parse the path to a uri
      Uri.parse('$_apiUrl$path'),
      // set the content type to json
      headers: {
        'content-type': 'application/json',
      },
      // set the body to the json
      body: body,
    );
  }
}

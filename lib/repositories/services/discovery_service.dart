import 'dart:async';
import 'dart:convert' as JSON;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/services/crash_reporter.dart';
import 'package:rxdart/rxdart.dart';

class DiscoveryService {
  late ApplicationApi _applicationApi;
  late BaseResponse<Map<String, dynamic>> discoveryResponse;
  late StreamController<BaseResponse<Map<String, dynamic>>> _discoveryResponses;
  final Logger _logger = Logger('DiscoveryService');

  Stream<BaseResponse<Map<String, dynamic>>> get discoveryResponses => _discoveryResponses.stream;

  DiscoveryService(ApplicationApi applicationApi) {
    _applicationApi = applicationApi;
    initialize();
  }

  void initialize() {
    discoveryResponse = BaseResponse({}, LOADING);
    _discoveryResponses = BehaviorSubject<BaseResponse<Map<String, dynamic>>>()..add(discoveryResponse);
  }

  Future<void> getTopicPage(int topicId) async {
    var topicMap = (discoveryResponse.data['items'] as List<dynamic>)
        .firstWhere((element) => element['@type'] == 'topic' && element['topic_id'] == topicId);
    // topicMap can't be null due to firstWhere
    var topic = Topic.fromJson(topicMap);
    if (topic.nextPageToken.isEmpty) {
      return;
    }
    var response = await _applicationApi.getTopicExperiences(topicId, pageToken: topic.nextPageToken);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var bodyJson = JSON.jsonDecode(response.body);
      Topic.addPage(bodyJson, topic);
      topicMap['experiences'] += bodyJson['experiences'];
      topicMap['next_page_token'] = bodyJson['next_page_token'];
    }
  }

  String handleDiscoveryError(Object error) {
    discoveryResponse = BaseResponse({'topics': [], 'trails': []}, ERROR)..errorText = error.toString();
    _discoveryResponses.add(discoveryResponse);
    return "";
  }

  String handleDiscoveryResponse(http.Response response) {
    var responseCode = response.statusCode;
    if (responseCode >= 400) {
      return handleDiscoveryError(response.body);
    }
    Map<String, dynamic> responseBody = JSON.jsonDecode(response.body) as Map<String, dynamic>;
    var discoveryItems =
        discoveryResponse.responseStatus == SUCCESS ? discoveryResponse.data['items'] as List<dynamic> : [];
    _logger.info("adding ${responseBody['items'].length} items to existing ${discoveryItems.length} items");
    discoveryItems.addAll(responseBody['items']);
    discoveryResponse = BaseResponse({'items': discoveryItems}, SUCCESS);
    _discoveryResponses.add(discoveryResponse);
    if (responseBody.containsKey("next_page_token")) {
      return responseBody["next_page_token"];
    }
    return "";
  }

  Future<String> getDiscoveryPage({String? pageToken}) async {
    try {
      var response = await _applicationApi.getDiscovery(pageToken: pageToken);
      return handleDiscoveryResponse(response);
    } catch (error, stackTrace) {
      CrashReporter.reportError(
        error,
        stackTrace,
        context: 'Failed to get discovery page',
        attributes: {
          'has_page_token': pageToken != null,
          'page_token_length': pageToken?.length ?? 0,
        },
      );
      return handleDiscoveryError(error);
    }
  }

  List<Trail> loadTrailsFromResponseBody(Map<String, dynamic> response) {
    final List<Trail> trails = [];
    for (var trailMap in response['featuredTrails']['entries'] as List) {
      Trail trail = Trail.fromJson(trailMap as Map<String, dynamic>);
      trails.add(trail);
    }
    return trails;
  }

  List<Topic> loadTopicsFromResponseBody(Map<String, dynamic> response) {
    final List<Topic> topics = [];
    for (var topicMap in response['topics'] as List) {
      Topic topic = Topic.fromJson(topicMap as Map<String, dynamic>);
      topics.add(topic);
    }
    return topics;
  }

  int getNextPage(Map<String, dynamic> response) {
    int totalTopics = response['topicsExperiences']?.length ?? 0;
    return totalTopics <= 0 ? -1 : response['pagination']['nextPage'];
  }
}

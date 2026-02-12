import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/config/config.dart';
import 'package:onetwotrail/repositories/enums/trail_status.dart';
import 'package:onetwotrail/repositories/models/base_response.dart' as ott;
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/issue.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/restart.dart';
import 'package:onetwotrail/services/crash_reporter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationApiContext {
  final String token;
  final bool firstTime;
  final bool isAdmin;

  bool get hasToken => token.isNotEmpty;

  ApplicationApiContext(
    String? token,
    this.firstTime,
    this.isAdmin,
  ) : token = token ?? '';
}

String emptyDiscover = '{ "entries": [] }';
String discoverCacheKey = 'TRAILS_RESPONSE';

class ApplicationApi {
  late StreamController<ApplicationApiContext> contextStream;
  ApplicationApiContext _context = ApplicationApiContext('', true, false);
  late String _baseUrl;
  late Duration _timeout;
  late Logger _log;
  late SharedPreferences _preferences;

  ApplicationApi(String baseUrl, Duration timeout, SharedPreferences preferences) {
    contextStream = StreamController<ApplicationApiContext>.broadcast();
    _baseUrl = "$baseUrl/v1";
    _timeout = timeout;
    _log = Logger((ApplicationApi).toString());
    _preferences = preferences;
  }

  ApplicationApi.initialize(Config config, SharedPreferences preferences)
      : this(
          config.apiUrl,
          Duration(seconds: 60),
          preferences,
        );

  ApplicationApiContext get context => _context;

  Future<ApplicationApiContext> registeredContext() async {
    _log.info("Checking for registered context");
    if (_context.hasToken) {
      _log.info("Using existing context with token");
      return _context;
    }
    _log.info("No token in context, waiting for token from stream");
    try {
      _context = await contextStream.stream.firstWhere((apiToken) => apiToken.token.isNotEmpty);
      _log.info("Received context with token from stream");
    } catch (e) {
      _log.warning("Failed to get token from stream: $e");
      // Return the current context even if it doesn't have a token
    }
    return _context;
  }

  Future<String> _getBearer() async {
    _log.info("Getting bearer token");
    var context = await registeredContext();
    _log.info("Bearer token is ${context.token.isNotEmpty ? 'present' : 'empty'}");
    return context.token;
  }

  Future<void> updateContext({String? token, bool? pickTopics, bool? firstTime, bool? isAdmin}) async {
    _log.fine("Updating context token=$token pickTopics=$pickTopics firstTime=$firstTime isAdmin=$isAdmin");
    try {
      // Initialize default values if not provided and not in preferences
      bool pickTopicsValue =
          pickTopics ?? (_preferences.containsKey("pickTopics") ? _preferences.getBool('pickTopics')! : false);

      bool firstTimeValue =
          firstTime ?? (_preferences.containsKey("firstTime") ? _preferences.getBool('firstTime')! : true);

      String tokenValue = token ?? (_preferences.containsKey("token") ? _preferences.getString('token')! : '');

      bool isAdminValue = isAdmin ?? (_preferences.containsKey('isAdmin') ? _preferences.getBool('isAdmin')! : false);

      _log.info(
          "Found token in preferences: ${tokenValue.isNotEmpty ? 'present' : 'empty'} pickTopics=$pickTopicsValue firstTime=$firstTimeValue isAdmin=$isAdminValue");

      // Save values to preferences
      await _preferences.setBool('pickTopics', pickTopicsValue);
      await _preferences.setBool("firstTime", firstTimeValue);
      await _preferences.setString('token', tokenValue);
      await _preferences.setBool('isAdmin', isAdminValue);

      // Restart the app if token is updated and firstTime is not provided
      if (token != null && firstTime == null) {
        _log.fine("Restarting application");
        return RestartWidget.restart();
      }

      // Create new context
      _context = ApplicationApiContext(tokenValue, firstTimeValue, isAdminValue);
      contextStream.add(_context);
      _log.info(
          "Updated context: hasToken=${_context.hasToken} firstTime=${_context.firstTime} isAdmin=${_context.isAdmin}");
    } catch (exception, stackTrace) {
      CrashReporter.reportError(
        exception,
        stackTrace,
        context: 'Failed to update application context',
        attributes: {
          'has_token': token != null,
          'pick_topics': pickTopics,
          'first_time': firstTime,
          'is_admin': isAdmin,
        },
      );
      return updateContext(token: '');
    }
  }

  Future<Response> doHttpCall(Future<http.Response> Function() call, {int retries = 3}) async {
    late Response response;
    while (retries > 0) {
      try {
        response = await call().timeout(_timeout);
        if (response.statusCode == 429) {
          retries--;
          _log.fine("http: rate limit exceeded: retrying $retries more times");
          sleep(Duration(seconds: 1));
          continue;
        }
        break;
      } catch (e, stackTrace) {
        CrashReporter.reportError(
          e,
          stackTrace,
          context: 'Failed to make HTTP call',
          attributes: {
            'retries_remaining': retries,
            'base_url': _baseUrl,
          },
        );
        return Response('', HttpStatus.internalServerError);
      }
    }
    if (response.statusCode == 401) {
      _log.warning("http: unauthorized");
      await updateContext(token: '');
    }
    if (response.statusCode >= 400 && response.statusCode < 500) {
      _log.warning("http: client error (${response.statusCode})", response.body);
      _logErrorsFromResponse(response);
    }
    if (response.statusCode >= 500) {
      _log.severe("http: system error (${response.statusCode})", response.body);
    }
    return response;
  }

  void _logErrorsFromResponse(Response response) {
    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body.containsKey('errors') && body['errors'] != null) {
        final errors = body['errors'];
        if (errors is List) {
          for (var error in errors) {
            if (error is Map && error.containsKey('message')) {
              _log.warning("http: error from server: ${error['message']}");
            } else {
              _log.warning("http: error from server: $error");
            }
          }
        } else {
          _log.warning("http: error from server: $errors");
        }
      }
    } catch (e) {
      _log.fine("http: could not parse errors from response body");
    }
  }

  Future<http.Response> doHttpGet(String path,
      {bool allowUnregistered = false, bool preferRegistered = false, Map<String, String>? queryParameters}) async {
    _log.info("Preparing HTTP GET request to $path");
    var headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };

    preferRegistered = preferRegistered && _context.hasToken;
    _log.info("User has token: ${_context.hasToken}");

    if (!allowUnregistered || preferRegistered) {
      var token = await _getBearer();
      _log.info("Adding authorization header with token: ${token.isNotEmpty ? 'present' : 'empty'}");
      headers['Authorization'] = 'Bearer $token';
    } else {
      _log.info("Skipping authorization header for unauthenticated request");
    }

    var url = Uri.parse("$_baseUrl/$path");
    url = url.replace(queryParameters: queryParameters);
    _log.info("Sending HTTP GET request to $url");

    return doHttpCall(() => http.get(url, headers: headers));
  }

  Future<http.Response> doHttpPost(String path, Map<String, dynamic> body,
      {String? baseUrl, bool allowUnregistered = false}) async {
    var headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
    if (!allowUnregistered) {
      headers['Authorization'] = 'Bearer ${await _getBearer()}';
    }
    var url = Uri.parse("$_baseUrl/$path");
    return doHttpCall(() => http.post(url, headers: headers, body: jsonEncode(body)));
  }

  Future<http.Response> doHttpPatch(String path, Map<String, dynamic> body,
      {String? baseUrl, bool allowUnregistered = false}) async {
    var headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
    if (!allowUnregistered) {
      headers['Authorization'] = 'Bearer ${await _getBearer()}';
    }
    var url = Uri.parse("$_baseUrl/$path");
    return doHttpCall(() => http.patch(url, headers: headers, body: jsonEncode(body)));
  }

  Future<http.Response> doHttpPut(String path, Map<String, dynamic> body,
      {String? baseUrl, bool allowUnregistered = false}) async {
    var headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
    if (!allowUnregistered) {
      headers['Authorization'] = 'Bearer ${await _getBearer()}';
    }
    var url = Uri.parse("$_baseUrl/$path");
    return doHttpCall(() => http.put(url, headers: headers, body: jsonEncode(body)));
  }

  Future<http.Response> doHttpDelete(String path, {String? baseUrl, bool allowUnregistered = false}) async {
    var headers = {
      'Accept': 'application/json',
    };
    if (!allowUnregistered) {
      headers['Authorization'] = 'Bearer ${await _getBearer()}';
    }
    var url = Uri.parse("$_baseUrl/$path");
    return doHttpCall(() => http.delete(url, headers: headers));
  }

  Future<Response> signUp(String firstName, String lastName, String email, String password, String countryCode) async {
    _log.fine("signing up $email");
    final body = <String, dynamic>{
      "first_name": firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'country': countryCode,
    };
    return await doHttpPost("auth/register", body, allowUnregistered: true);
  }

  Future<Response> signInWithEmailAndPassword(String email, String password) async {
    _log.fine("signing in $email");
    var body = {
      "email": email,
      "password": password,
    };
    return doHttpPost('auth/email', body, allowUnregistered: true);
  }

  Future<ApplicationApiResponse> signInWithEmailAndPasswordProxy(String email, String password) async {
    Response response = await signInWithEmailAndPassword(email, password);
    if (response.statusCode >= 400) {
      return ApplicationApiResponse(
          statusCode: response.statusCode,
          responseBody: response.body,
          result: false,
          responseObject: User(
              id: 0,
              firstName: '',
              lastName: '',
              email: email,
              isLogged: false,
              trails: [],
              pickTopics: false,
              country: '',
              phoneNumber: '',
              avatar: '',
              selectCountry: true,
              visitedExperiences: [],
              password: false));
    }
    Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    await updateContext(
      token: data['token'],
      pickTopics: data['pick_topics'],
      isAdmin: data['is_admin'],
    );
    return ApplicationApiResponse(
        statusCode: response.statusCode,
        result: true,
        responseBody: response.body,
        responseObject: User(
            id: 0,
            email: email,
            firstName: '',
            lastName: '',
            isLogged: true,
            pickTopics: false,
            password: false,
            phoneNumber: '',
            country: '',
            avatar: '',
            selectCountry: data['select_country'] ?? true,
            trails: [],
            visitedExperiences: []));
  }

  Future<Response> signInWithFacebook(String token) async {
    _log.fine("signing in with facebook");
    var body = {"access_token": token};
    return doHttpPost("auth/facebook", body, allowUnregistered: true);
  }

  Future<Response> sendResetPasswordEmail(String email) async {
    _log.fine("sending reset password to $email");
    var body = {
      "email": email,
    };
    return doHttpPatch("auth/forgotPassword", body, allowUnregistered: true);
  }

  Future<Response> checkCodeInApi(String passwordToken, String password, String passwordConfirmation) async {
    _log.fine("resetting password");
    var body = {
      "reset_password_token": passwordToken,
      "password": password,
      "password_confirmation": passwordConfirmation
    };
    return doHttpPut("auth/forgotPassword", body);
  }

  Future<Response> getDiscovery({int pageSize = 6, String? pageToken}) async {
    var hasPageToken = pageToken != null && pageToken.length > 0;
    _log.fine("getting discovery pageSize=$pageSize pageToken=$hasPageToken");
    Map<String, dynamic> body = {"page_size": pageSize};
    if (hasPageToken) {
      body['page_token'] = pageToken;
    }
    return doHttpPost("discovery", body, allowUnregistered: true);
  }

  Future<Response> getTopicExperiences(int topicId, {int pageSize = 25, String? pageToken}) async {
    var hasPageToken = pageToken != null && pageToken.isNotEmpty;
    _log.fine("getting experiences of topic $topicId pageToken=$hasPageToken");
    var body = {'topic_id': '$topicId', 'page_size': pageSize};
    if (hasPageToken) {
      body['page_token'] = pageToken;
    }
    return doHttpPost("discover_experiences_for_topic", body, allowUnregistered: true);
  }

  Future<Response> getSearchFilters() async {
    _log.fine("getting search filters");
    return doHttpGet('search/filters', allowUnregistered: true);
  }

  Future<Response> getSearchTerms() async {
    _log.fine("getting searchable terms");
    return doHttpGet('search/searchable_terms', allowUnregistered: true);
  }

  Future<Response> search(String searchQuery, Map<String, dynamic> filters, int page, int perPage) async {
    _log.fine("searching $searchQuery");
    var body = {'filters': filters.values.toList(), 'per_page': perPage, 'q': searchQuery, 'page': page};
    return doHttpPost('search', body, allowUnregistered: true);
  }

  Future<Response> _updateTrailFromMap(Map<String, Object> trail, int trailId) async {
    var body = {'trail': trail};
    return doHttpPut("trails/$trailId", body);
  }

  Future<ApplicationApiResponse> reportExperience(Issue issue, String painLevel) async {
    _log.fine("reporting experience ${issue.idExperience}");
    var body = {
      'flaggable_id': issue.idExperience,
      'flaggable_type': 'Experience',
      'comment': issue.comment,
      'report_types': issue.reportType,
      'pain_level': painLevel
    };
    var response = await doHttpPost("flags", body);
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<Issue>(
        result: false,
        responseBody: response.body,
        statusCode: response.statusCode,
        responseObject: Issue.init(),
      );
    }
    return ApplicationApiResponse<Issue>(
      result: true,
      responseBody: response.body,
      statusCode: response.statusCode,
      responseObject: Issue.init(),
    );
  }

  Future<Response> _updateTrailFromFields(
      String name, String description, List<String> collaborators, int trailId, bool collaboratorsChanged) async {
    var body;
    if (description == "" && collaboratorsChanged) {
      body = {
        "trail": {"collaborators": collaborators, "name": name}
      };
    } else if (description != "" && collaborators.length == 0) {
      body = {
        "trail": {"description": description, "name": name, 'collaborators': []}
      };
    } else {
      body = {
        "trail": {'collaborators': collaborators, "description": description, "name": name}
      };
    }
    return doHttpPut("trails/$trailId", body);
  }

  Future<ApplicationApiResponse> hideExperience(int experienceId) async {
    _log.fine("hiding experience $experienceId");
    var body = {
      "experience_id": experienceId,
      "is_hidden": true,
    };
    var response = await doHttpPost('experiences/set_visibility', body);
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<void>(
        result: false,
        responseBody: response.body,
        statusCode: response.statusCode,
        responseObject: null,
      );
    }
    return ApplicationApiResponse<void>(
      result: true,
      responseBody: response.body,
      statusCode: response.statusCode,
      responseObject: null,
    );
  }

  Future<Response> validateEmail(String email) async {
    _log.fine("validating email $email");
    var body = {"email": email};
    return doHttpPost("auth/validate_email", body, allowUnregistered: true);
  }

  Future<Response> signInWithApple(String jwt, String userId, String code) async {
    _log.fine("signing in with apple");
    var body = {"jwt": jwt, "user_id": userId, "code": code};
    return doHttpPost("auth/apple", body, allowUnregistered: true);
  }

  Future<List<Topic>> getTopics({required int resultsPerPage, required String token}) async {
    _log.fine("getting topics page $resultsPerPage");
    var queryParameters = {
      "resultsPerPage": "$resultsPerPage",
    };
    queryParameters['token'] = token;
    var response = await doHttpGet("topics/list", allowUnregistered: true, queryParameters: queryParameters);
    if (response.statusCode >= 400) {
      return [];
    }
    Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final List<Topic> topics = [];
    for (var topicData in data['entries'] as List) {
      Topic newTopic = Topic(
        id: topicData['id'] as int,
        name: topicData['name'] as String,
        imageUrl: topicData['image'] as String,
        experiences: [],
        description: '',
        nextPageToken: '',
        resultsPerPage: 0,
      );
      topics.add(newTopic);
    }
    return topics;
  }

  Future<Experience?> getExperience(int experienceId) async {
    _log.fine("getting experience $experienceId");
    var response = await doHttpGet('experiences/$experienceId', allowUnregistered: true);
    if (response.statusCode >= 400) {
      return null;
    }
    Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return Experience.fromJson(data);
  }

  Future<User?> getUserProfileInfo() async {
    _log.info("Getting user profile info...");
    var response = await doHttpGet("account/profile");
    if (response.statusCode != HttpStatus.ok) {
      _log.warning("Failed to get user profile: ${response.statusCode}");
      return null;
    }
    Map<String, dynamic> extractedData = json.decode(response.body) as Map<String, dynamic>;
    _log.info("Got raw user profile data: ${extractedData}");
    _log.info("Got country from API: ${extractedData['country']}");
    final User user = User.fromJson(extractedData);
    _log.info("User country after parsing: ${user.country}");
    return user;
  }

  Future<ott.BaseResponse<User>> updateUserProfile(Map<String, Object> profile) async {
    _log.info("Updating user profile info with data: $profile");

    var response = await doHttpPut("account/profile", profile);
    if (response.statusCode >= 400) {
      _log.warning("Failed to update user profile: ${response.statusCode}");
      _log.warning("Response body: ${response.body}");
      return ott.BaseResponse<User>(
          User(
              id: 0,
              firstName: '',
              lastName: '',
              email: '',
              isLogged: false,
              trails: [],
              pickTopics: false,
              country: '',
              phoneNumber: '',
              avatar: '',
              selectCountry: true,
              visitedExperiences: [],
              password: false),
          ott.ERROR);
    }
    Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    _log.info("Updated user profile successfully");
    return ott.BaseResponse<User>(User.fromJson(data), ott.SUCCESS);
  }

  Future<User> updateUserPassword(String newPassword, {String? oldPassword}) async {
    _log.info("updating user password");
    var body = {
      "new": newPassword,
    };
    if (oldPassword != null) {
      body["old"] = oldPassword;
    }
    var response = await doHttpPut("account/password", body);
    Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<ApplicationApiResponse<List<Trail>>> getUserTrails({int? pageSize, String? pageToken}) async {
    _log.info("getting user trails with pageSize=$pageSize pageToken=${pageToken != null ? 'present' : 'null'}");

    Map<String, String> queryParameters = {};
    if (pageSize != null) {
      queryParameters['page_size'] = pageSize.toString();
    }
    if (pageToken != null && pageToken.isNotEmpty) {
      queryParameters['page_token'] = pageToken;
    }

    var response = await doHttpGet("trails", queryParameters: queryParameters.isNotEmpty ? queryParameters : null);
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<List<Trail>>(
          statusCode: response.statusCode, result: false, responseBody: "", responseObject: []);
    }

    var parseResult = await _parseSearchResultTrailsWithPagination(response.body);
    return ApplicationApiResponse<List<Trail>>(
        statusCode: response.statusCode,
        result: true,
        responseBody: "",
        responseObject: parseResult['trails'],
        nextPageToken: parseResult['nextPageToken']);
  }

  Future<Map<String, dynamic>> _parseSearchResultTrailsWithPagination(String body) async {
    Map<String, dynamic> parse = json.decode(body) as Map<String, dynamic>;
    List<Trail> trails = [];
    
    final entries = parse['entries'];
    if (entries is List) {
      for (var value in entries) {
        trails.add(Trail.fromJson(value as Map<String, dynamic>));
      }
    }

    String? nextPageToken;
    if (parse.containsKey('pagination') && parse['pagination'] != null) {
      var pagination = parse['pagination'] as Map<String, dynamic>;
      var token = pagination['next_page_token'];
      if (token != null) {
        nextPageToken = token.toString();
      }
    }

    return {'trails': trails, 'nextPageToken': nextPageToken};
  }

  Future<ott.BaseResponse<Trail>> getTrail({required int trailId}) async {
    _log.info("getting trail $trailId");
    var response = await doHttpGet('trails/$trailId', allowUnregistered: true, preferRegistered: true);
    Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      return ott.BaseResponse<Trail>(
          Trail(
            id: 0,
            author: '',
            collaborators: [],
            description: '',
            experiences: [],
            itineraryEstimatedTime: Duration.zero,
            itineraryId: 0,
            latitude: 0.0,
            listingDescription: '',
            lockVersion: 0,
            longitude: 0.0,
            name: '',
            status: TrailStatus.PAUSED,
          ),
          ott.ERROR);
    }
    Trail trail = Trail.fromJson(body);
    return ott.BaseResponse<Trail>(trail, ott.SUCCESS);
  }

  Future<bool> removeExperience(Map<String, Object> trail, int trailId) async {
    _log.info("removing experience from trail $trailId");
    final response = await _updateTrailFromMap(trail, trailId);
    return response.statusCode == 200;
  }

  Future<ott.BaseResponse<Trail>> createTrail(Map<String, Object> trailMap) async {
    _log.info("creating trail");
    final requestBody = {'trail': trailMap};
    var response = await doHttpPost("trails", requestBody);
    if (response.statusCode >= 400) {
      return ott.BaseResponse<Trail>(
          Trail(
            id: 0,
            author: '',
            collaborators: [],
            description: '',
            experiences: [],
            itineraryEstimatedTime: Duration.zero,
            itineraryId: 0,
            latitude: 0.0,
            listingDescription: '',
            lockVersion: 0,
            longitude: 0.0,
            name: '',
            status: TrailStatus.PAUSED,
          ),
          ott.ERROR)
        ..errorText = response.body;
    }
    Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
    Trail trail = Trail.fromJson(responseBody);
    return ott.BaseResponse<Trail>(trail, ott.SUCCESS);
  }

  Future<ApplicationApiResponse<Trail>> updateTrail(Map<String, Object> trailMap, int trailId) async {
    _log.info("updating trail $trailId");
    var response = await _updateTrailFromMap(trailMap, trailId);
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<Trail>(
        statusCode: 400,
        result: false,
        responseBody: response.body,
        responseObject: Trail(
          id: 0,
          author: '',
          collaborators: [],
          description: '',
          experiences: [],
          itineraryEstimatedTime: Duration.zero,
          itineraryId: 0,
          latitude: 0.0,
          listingDescription: '',
          lockVersion: 0,
          longitude: 0.0,
          name: '',
          status: TrailStatus.PAUSED,
        ),
      );
    }
    Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
    return ApplicationApiResponse<Trail>(
        statusCode: 200, result: true, responseBody: response.body, responseObject: Trail.fromJson(responseBody));
  }

  Future<ApplicationApiResponse> deleteTrail(Trail trail) async {
    _log.info("deleting trail ${trail.id}");
    var response = await doHttpDelete("trails/${trail.id}");
    if (response.statusCode >= 400) {
      ApplicationApiResponse<void> responseFromTheApiObject = ApplicationApiResponse<void>(
        statusCode: response.statusCode,
        responseBody: response.body,
        result: false,
        responseObject: null,
      );
      return responseFromTheApiObject;
    }
    return ApplicationApiResponse<void>(
      statusCode: response.statusCode,
      responseBody: response.body,
      result: true,
      responseObject: null,
    );
  }

  Future<ApplicationApiResponse<Trail>> publishTrail(Trail originalTrail) async {
    _log.info("publishing trail ${originalTrail.id}");
    var response = await doHttpPatch("trails/${originalTrail.id}/publish", {});
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<Trail>(
        statusCode: response.statusCode,
        result: false,
        responseBody: response.body,
        responseObject: originalTrail,
      );
    }
    Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
    return ApplicationApiResponse<Trail>(
      statusCode: response.statusCode,
      result: true,
      responseBody: response.body,
      responseObject: Trail.fromJson(responseBody),
    );
  }

  Future<ApplicationApiResponse<Trail>> unpublishTrail(Trail originalTrail) async {
    _log.info("unpublishing trail ${originalTrail.id}");
    var response = await doHttpPatch("trails/${originalTrail.id}/unpublish", {});
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<Trail>(
        statusCode: response.statusCode,
        result: false,
        responseBody: response.body,
        responseObject: originalTrail,
      );
    }
    Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
    return ApplicationApiResponse<Trail>(
      statusCode: response.statusCode,
      result: true,
      responseBody: response.body,
      responseObject: Trail.fromJson(responseBody),
    );
  }

  Future<ApplicationApiResponse<Itinerary>> getItinerary(int itineraryId) async {
    _log.info("getting itinerary $itineraryId");
    var response = await doHttpGet('itineraries/$itineraryId');
    Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<Itinerary>(
          statusCode: response.statusCode,
          result: false,
          responseBody: "",
          responseObject: Itinerary(
            id: 0,
            trailId: 0,
            adultParticipantsCount: 0,
            teenParticipantsCount: 0,
            kidsParticipantsCount: 0,
            startDate: '',
            endDate: '',
            startingExperienceId: 0,
            endingExperienceId: 0,
            events: [],
          ));
    }
    Itinerary itinerary = Itinerary.fromJson(responseBody);
    return ApplicationApiResponse<Itinerary>(
        statusCode: response.statusCode, result: true, responseBody: "", responseObject: itinerary);
  }

  Future<ApplicationApiResponse<Itinerary>> updateItineraryWithApplicationApiResponse(
      int itineraryId, Map<String, Object> data) async {
    var response = await _updateItinerary(itineraryId, data);
    Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<Itinerary>(
          statusCode: response.statusCode,
          result: false,
          responseBody: 'AppLocalizations.of(context).somethingWentWrongText',
          responseObject: Itinerary(
            id: 0,
            trailId: 0,
            adultParticipantsCount: 0,
            teenParticipantsCount: 0,
            kidsParticipantsCount: 0,
            startDate: '',
            endDate: '',
            startingExperienceId: 0,
            endingExperienceId: 0,
            events: [],
          ));
    }
    Itinerary itinerary;
    itinerary = Itinerary.fromJson(responseBody);
    return ApplicationApiResponse<Itinerary>(
        statusCode: response.statusCode, result: true, responseBody: response.body, responseObject: itinerary);
  }

  Future<Response> _updateItinerary(int itineraryId, Map<String, Object> requestBody) async {
    _log.info("updating itinerary $itineraryId");
    var response = await doHttpPut("itineraries/$itineraryId", requestBody);
    return response;
  }

  Future<ApplicationApiResponse<Trail>> updateTrailFromFields(String name, String smallDescription,
      List<String> listOfCollaborators, int trailId, bool listOfCollaboratorsChange) async {
    _log.info("updating trail $trailId from fields");
    Response response =
        await _updateTrailFromFields(name, smallDescription, listOfCollaborators, trailId, listOfCollaboratorsChange);
    if (response.statusCode == 422) {
      String emails = '';
      final emailPattern = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b', caseSensitive: false, multiLine: true);
      final matches = emailPattern.allMatches(response.body);
      for (final Match match in matches) {
        emails += response.body.substring(match.start, match.end) + "\n";
      }
      return ApplicationApiResponse<Trail>(
        responseBody: emails,
        statusCode: response.statusCode,
        result: false,
        responseObject: Trail(
          id: 0,
          author: '',
          collaborators: [],
          description: '',
          experiences: [],
          itineraryEstimatedTime: Duration.zero,
          itineraryId: 0,
          latitude: 0.0,
          listingDescription: '',
          lockVersion: 0,
          longitude: 0.0,
          name: '',
          status: TrailStatus.PAUSED,
        ),
      );
    }
    if (response.statusCode >= 400) {
      return ApplicationApiResponse<Trail>(
        responseBody: response.body,
        statusCode: response.statusCode,
        result: false,
        responseObject: Trail(
          id: 0,
          author: '',
          collaborators: [],
          description: '',
          experiences: [],
          itineraryEstimatedTime: Duration.zero,
          itineraryId: 0,
          latitude: 0.0,
          listingDescription: '',
          lockVersion: 0,
          longitude: 0.0,
          name: '',
          status: TrailStatus.PAUSED,
        ),
      );
    }
    var trail = Trail.fromJson(json.decode(response.body) as Map<String, dynamic>);
    return ApplicationApiResponse<Trail>(
        responseBody: response.body, statusCode: response.statusCode, responseObject: trail, result: true);
  }

  Future<ott.BaseResponse<void>> deleteAccount() async {
    _log.info("deleting account");
    var response = await doHttpDelete("account/profile");
    if (response.statusCode >= 400) {
      return ott.BaseResponse(null, ott.ERROR);
    }
    await updateContext(token: '');
    _log.info("deleted account");
    return ott.BaseResponse(null, ott.SUCCESS);
  }

  Future<Response> sendVerificationEmail(String email) {
    _log.info("sending confirmation email to $email");
    return doHttpPost("auth/verification", {"email": email}, allowUnregistered: true);
  }
}

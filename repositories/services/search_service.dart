import 'dart:async';
import 'dart:convert' as JSON;

import 'package:onetwotrail/constants.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/services/crash_reporter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  late ApplicationApi applicationApi;
  late SharedPreferences preferences;

  int _currentPage = 1;
  List<Experience> _searchResults = [];
  bool _isLoadingSearch = false;
  bool _hasMoreResults = true;
  String _currentSearchQuery = '';
  Map<String, dynamic> _currentFilters = {};
  bool _isInitialized = false;

  StreamController<ApplicationApiResponse<List<Experience>>> _searchStreamController = BehaviorSubject();
  StreamController<bool> _loadingStateController = BehaviorSubject<bool>.seeded(false);
  StreamController<List<String>> _searchableTermsController = BehaviorSubject<List<String>>();

  SearchService(this.applicationApi, this.preferences);

  Stream<ApplicationApiResponse<List<Experience>>> initSearch(String query, Map<String, dynamic> filters) {
    _currentSearchQuery = query;
    _currentFilters = filters;
    _currentPage = 1;
    _searchResults = [];
    _hasMoreResults = true;
    _isInitialized = true;

    loadSearchPage();
    return _searchStreamController.stream;
  }

  Future<void> loadSearchPage() async {
    if (_isLoadingSearch || (_searchResults.isNotEmpty && !_hasMoreResults)) {
      return;
    }

    _setLoadingState(true);

    try {
      var response = await applicationApi.search(_currentSearchQuery, _currentFilters, _currentPage, Constants.SEARCH_PAGE_SIZE);
      _setLoadingState(false);

      if (response.statusCode == 200) {
        Map<String, dynamic> parsedData = _parseSearchResponse(response.body);
        List<Experience> experiences = parsedData['experiences'];
        bool hasMore = parsedData['hasMore'];

        _searchResults.addAll(experiences);
        _hasMoreResults = hasMore;

        var controllerResponse = ApplicationApiResponse<List<Experience>>(
          statusCode: response.statusCode,
          result: true,
          responseBody: response.body,
          responseObject: List.from(_searchResults),
        );

        _searchStreamController.add(controllerResponse);
      } else {
        _currentPage--;
        
        if (response.statusCode >= 400 && response.statusCode < 500) {
          _hasMoreResults = false;
        }
        
        var controllerResponse = ApplicationApiResponse<List<Experience>>(
          statusCode: response.statusCode,
          result: false,
          responseBody: response.body,
          responseObject: _searchResults,
        );
        _searchStreamController.add(controllerResponse);
      }
    } catch (e, stackTrace) {
      _setLoadingState(false);
      _currentPage--;
      
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to search for experiences',
        attributes: {
          'search_query': _currentSearchQuery,
          'page': _currentPage,
          'filters_count': _currentFilters.length,
        },
      );

      var controllerResponse = ApplicationApiResponse<List<Experience>>(
        statusCode: 500,
        result: false,
        responseBody: e.toString(),
        responseObject: _searchResults,
      );
      _searchStreamController.add(controllerResponse);
    }
  }

  Future<void> loadNextSearchPage() async {
    if (!_hasMoreResults || _isLoadingSearch) return;
    _currentPage++;
    await loadSearchPage();
  }

  void resetSearch() {
    _currentPage = 1;
    _searchResults = [];
    _hasMoreResults = true;
    _currentSearchQuery = '';
    _currentFilters = {};
    _isInitialized = false;
    _setLoadingState(false);
  }

  void _setLoadingState(bool isLoading) {
    _isLoadingSearch = isLoading;
    _loadingStateController.add(isLoading);
  }

  Map<String, dynamic> _parseSearchResponse(String body) {
    Map<String, dynamic> parsed = JSON.json.decode(body);
    List<Experience> experiences = [];

    if (parsed.containsKey('entries')) {
      for (var value in parsed['entries']) {
        experiences.add(Experience.fromJson(value as Map<String, dynamic>));
      }
    }

    int perPage = Constants.SEARCH_PAGE_SIZE;
    if (parsed.containsKey('paginate') && parsed['paginate'] != null) {
      var paginate = parsed['paginate'] as Map<String, dynamic>;
      if (paginate.containsKey('per_page')) {
        perPage = paginate['per_page'] as int;
      }
    }

    bool hasMore = experiences.length >= perPage;

    return {
      'experiences': experiences,
      'hasMore': hasMore,
    };
  }

  Stream<List<String>> getSearchableTerms() {
    List<String> cachedSearchableTerms = preferences.getStringList('SEARCHABLE_TERMS') ?? [];
    _searchableTermsController.add(cachedSearchableTerms);

    applicationApi.getSearchTerms().then((result) {
      try {
        if (result.statusCode == 200) {
          List<dynamic> results = JSON.json.decode(result.body);
          List<String> mappedResults = results.map((e) => e.toString()).toList();
          mappedResults.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          _searchableTermsController.add(mappedResults);
          preferences.setStringList('SEARCHABLE_TERMS', mappedResults);
        }
      } catch (ex, stackTrace) {
        CrashReporter.reportError(
          ex,
          stackTrace,
          context: 'Failed to get searchable terms',
          attributes: {
            'response_status_code': result.statusCode,
          },
        );
        _searchableTermsController.add([]);
        preferences.setStringList('SEARCHABLE_TERMS', []);
      }
    });

    return _searchableTermsController.stream;
  }

  bool get isLoadingSearch => _isLoadingSearch;
  bool get hasMoreResults => _hasMoreResults;
  bool get isInitialLoad => !_isInitialized && _searchResults.isEmpty && _isLoadingSearch;
  Stream<ApplicationApiResponse<List<Experience>>> get searchStream => _searchStreamController.stream;
  Stream<bool> get loadingStateStream => _loadingStateController.stream;

  void dispose() {
    _searchStreamController.close();
    _loadingStateController.close();
    _searchableTermsController.close();
  }
}

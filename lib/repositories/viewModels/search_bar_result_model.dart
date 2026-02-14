import 'dart:async';
import 'dart:convert' as JSON;

import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/search.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/repositories/services/search_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:rxdart/rxdart.dart';

class SearchBarResultModel extends BaseModel {
  late SearchService _searchService;
  late ApplicationApi _applicationApi;

  bool _isSearching = false;
  bool searchFocus = false;
  bool _showSearch = false;
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  String? _search;
  FocusNode _tileFocus = FocusNode();
  bool _showClearTextButton = false;
  String _lastSearchTerm = "";
  List<String> recentSearchesTerms = [];

  bool get showSearch => _showSearch;
  bool get isLoading => _isLoading;
  List<Search> _totalSearchList = [];
  bool searchable = true;
  List<String> searchableTermsList = [];
  StreamController<List<String>> _autocompleteData = BehaviorSubject();
  // Autocomplete experience suggestions (used by the autofill widget)
  StreamController<List<Experience>> _autocompleteExperienceData =
      BehaviorSubject<List<Experience>>();
  String _prevSearchTerm = '';
  Timer? _debounce;

  StreamSubscription<List<String>>? _searchableTermsSubscription;
  StreamSubscription<ApplicationApiResponse<List<Experience>>>?
      _searchStreamSubscription;
  StreamSubscription<bool>? _loadingStateSubscription;

  String get lastSearchTerm => _lastSearchTerm;

  bool get showClearTextButton => _showClearTextButton;

  List<Experience> searchResults = [];

  // Cache for placeholder data (trials, lead experiences, experiences sample)
  List<Trail> cachedTrialSample = [];
  List<Experience> cachedLeadExperienceSample = [];
  List<Experience> cachedExperienceSample = [];

  TextEditingController get searchController => _searchController;
  ScrollController get scrollController => _scrollController;

  SearchService get searchService => _searchService;

  bool get isSearching => _isSearching;

  List<Search> get totalPlacesList => _totalSearchList;

  List<Search> get totalSearchList => _totalSearchList;

  String? get search => _search;

  FocusNode get tileFocus => _tileFocus;

  set tileFocus(FocusNode value) {
    _tileFocus = value;
    notifyListeners();
  }

  set search(String? value) {
    _search = value;
    notifyListeners();
  }

  set totalSearchList(List<Search> value) {
    _totalSearchList = value;
    notifyListeners();
  }

  set totalPlacesList(List<Search> value) {
    _totalSearchList = value;
    notifyListeners();
  }

  set isSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  FocusNode _focusNode = new FocusNode();

  FocusNode get focusNode => _focusNode;

  Search? _searchEntry;

  Search? get searchEntry => _searchEntry;

  set searchEntry(Search? value) {
    _searchEntry = value;
    notifyListeners();
  }

  User? user;

  String? textSearch;

  String get prevSearchTerm => _prevSearchTerm;

  Stream<List<String>> get autocompleteData => _autocompleteData.stream;
  Stream<List<Experience>> get autocompleteExperienceData =>
      _autocompleteExperienceData.stream;

  bool get isLoadingMore => _searchService.isLoadingSearch;
  bool get hasMoreResults => _searchService.hasMoreResults;

  Future<void> initSearch() async {
    _searchController.addListener(() {
      String searchTerm = _searchController.text;
      if (_prevSearchTerm != searchTerm) {
        searchable = (searchTerm.isEmpty && recentSearchesTerms.isNotEmpty) ||
            (searchTerm.isNotEmpty && searchableTermsList.isNotEmpty);
      }

      _prevSearchTerm = searchTerm;
      _showClearTextButton = searchTerm.isNotEmpty;

      if (_showClearTextButton && searchableTermsList.isNotEmpty) {
        if (_debounce != null && _debounce!.isActive) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 100), () {
          _autocompleteData.add(searchableTermsList
              .where((element) =>
                  element.toLowerCase().contains(searchTerm.toLowerCase()))
              .toList());
          // fetch a small set of experience suggestions (thumbnails + names)
          _fetchAutocompleteExperiences(searchTerm);
        });
      }
      notifyListeners();
    });

    _scrollController.addListener(_onScroll);

    recentSearchesTerms = [];
    searchable = recentSearchesTerms.isNotEmpty;

    _searchableTermsSubscription =
        _searchService.getSearchableTerms().listen((event) {
      searchableTermsList = event;
    });

    _searchStreamSubscription = _searchService.searchStream.listen((response) {
      if (response.result) {
        searchResults = response.responseObject;
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    });

    _loadingStateSubscription =
        _searchService.loadingStateStream.listen((isLoading) {
      notifyListeners();
    });
  }

  /// Initialize cached placeholder samples from discovery data (called once to prevent re-sampling)
  void initializeCachedSamples(
      List<Experience> allExperiences, List<Trail> allTrails) {
    // Only initialize if not already done
    if (cachedLeadExperienceSample.isEmpty && allExperiences.isNotEmpty) {
      final shuffledExperiences = List<Experience>.from(allExperiences);
      shuffledExperiences.shuffle();

      cachedLeadExperienceSample = shuffledExperiences.take(7).toList();
      cachedExperienceSample = shuffledExperiences.skip(7).take(9).toList();
    }

    if (cachedTrialSample.isEmpty && allTrails.isNotEmpty) {
      final shuffledTrails = List<Trail>.from(allTrails);
      shuffledTrails.shuffle();

      cachedTrialSample = shuffledTrails.take(5).toList();
    }
  }

  /// Fetch up to 8 experiences matching the partial search term for autocomplete
  void _fetchAutocompleteExperiences(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        _autocompleteExperienceData.add([]);
        return;
      }

      final response = await _applicationApi.search(searchTerm, {}, 1, 8);
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed = JSON.json.decode(response.body);
        final List<Experience> experiences = [];
        if (parsed.containsKey('entries')) {
          for (var entry in parsed['entries']) {
            try {
              experiences
                  .add(Experience.fromJson(entry as Map<String, dynamic>));
            } catch (_) {}
          }
        }
        _autocompleteExperienceData.add(experiences);
      } else {
        _autocompleteExperienceData.add([]);
      }
    } catch (_) {
      _autocompleteExperienceData.add([]);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (isLoadingMore || !hasMoreResults) return;
    if (!_showSearch) return;

    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double threshold = _scrollController.position.viewportDimension;

    if (maxScroll - currentScroll <= threshold) {
      loadMoreResults();
    }
  }

  void loadMoreResults() {
    _searchService.loadNextSearchPage();
  }

  changeSearchableState(bool value) {
    if (value) {
      String searchTerm = _searchController.text;
      searchable = (searchTerm.isEmpty && recentSearchesTerms.isNotEmpty) ||
          (searchTerm.isNotEmpty && searchableTermsList.isNotEmpty);

      // When search field is focused with empty text, show popular/featured experiences
      if (searchTerm.isEmpty) {
        _fetchDefaultExperiences();
      }
    } else {
      searchable = value;
      _autocompleteExperienceData.add([]);
    }

    notifyListeners();
  }

  /// Fetch default featured experiences to show when search field is open but empty
  void _fetchDefaultExperiences() async {
    try {
      final response = await _applicationApi.search('', {}, 1, 8);
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed = JSON.json.decode(response.body);
        final List<Experience> experiences = [];
        if (parsed.containsKey('entries')) {
          for (var entry in parsed['entries']) {
            try {
              experiences
                  .add(Experience.fromJson(entry as Map<String, dynamic>));
            } catch (_) {}
          }
        }
        _autocompleteExperienceData.add(experiences);
      } else {
        _autocompleteExperienceData.add([]);
      }
    } catch (_) {
      _autocompleteExperienceData.add([]);
    }
  }

  deleteRecentSearch(String term) {
    recentSearchesTerms
        .removeWhere((element) => element.toLowerCase() == term.toLowerCase());
    String searchTerm = _searchController.text;
    searchable = (searchTerm.isEmpty && recentSearchesTerms.isNotEmpty) ||
        (searchTerm.isNotEmpty && searchableTermsList.isNotEmpty);
    notifyListeners();
  }

  void submitSearch(String search) {
    if (search.isEmpty || search == "") return;

    _prevSearchTerm = search;
    _searchController.text = search;
    recentSearchesTerms.removeWhere(
        (element) => element.toLowerCase() == search.toLowerCase());
    recentSearchesTerms.add(search);
    recentSearchesTerms = recentSearchesTerms.reversed.toList();
    _lastSearchTerm = search;
    _showSearch = true;
    searchable = false;
    _isLoading = true;
    notifyListeners();

    searchResults = [];
    this.search = search;
    _searchService.initSearch(search, {});
  }

  void clearSearch() {
    searchResults = [];
    _showSearch = false;
    _isLoading = false;
    _searchController.clear();
    _searchService.resetSearch();
    changeSearchableState(false);
  }

  Future<ApplicationApiResponse> hideExperience(int id) async {
    setState(ViewState.Busy);
    ApplicationApiResponse result = await _applicationApi.hideExperience(id);
    setState(ViewState.Idle);
    return result;
  }

  StreamSubscription? _searchListener;

  StreamSubscription? get searchListener => _searchListener;

  set searchListener(StreamSubscription? value) {
    _searchListener = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _autocompleteData.close();
    _autocompleteExperienceData.close();
    _scrollController.dispose();
    _searchListener?.cancel();
    _debounce?.cancel();
    _searchableTermsSubscription?.cancel();
    _searchStreamSubscription?.cancel();
    _loadingStateSubscription?.cancel();
    super.dispose();
  }

  SearchBarResultModel(this._applicationApi, this._searchService);
}

import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/search.dart';
import 'package:onetwotrail/repositories/services/search_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class SearchBarItemModel extends BaseModel {
  List<Experience> _list = [];
  late SearchService _searchService;
  Debouncer<String> _debouncer = Debouncer<String>(Duration(milliseconds: 500), initialValue: '');
  bool _isSearching = false;
  bool searchFocus = false;
  FocusNode _searchFocusNode = new FocusNode();
  TextEditingController _searchController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  late String _search;
  FocusNode _tileFocus = new FocusNode();

  List<Search> _totalSearchList = [];
  List<Search> _filteredSearch = [];
  StreamController<List<Experience>> _temp = StreamController.broadcast();

  StreamController<List<Experience>> get temp => _temp;

  TextEditingController get searchController => _searchController;

  FocusNode get searchFocusNode => _searchFocusNode;

  SearchService get searchService => _searchService;

  bool get isSearching => _isSearching;

  List<Search> get totalPlacesList => _totalSearchList;

  List<Search> get totalSearchList => _totalSearchList;

  List<Search> get filteredSearch => _filteredSearch;

  Debouncer<String> get debouncer => _debouncer;

  List<Experience> get list => _list;

  ScrollController get scrollController => _scrollController;

  String get search => _search;

  FocusNode get tileFocus => _tileFocus;

  set tileFocus(FocusNode value) {
    _tileFocus = value;
    notifyListeners();
  }

  set search(String value) {
    _search = value;
    notifyListeners();
  }

  set scrollController(ScrollController value) {
    _scrollController = value;
    notifyListeners();
  }

  set temp(StreamController<List<Experience>> value) {
    _temp = value;
    notifyListeners();
  }

  set list(List<Experience> value) {
    _list = value;
    notifyListeners();
  }

  set debouncer(Debouncer<String> value) {
    _debouncer = value;
    notifyListeners();
  }

  set filteredSearch(List<Search> value) {
    _filteredSearch = value;
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

  set searchService(SearchService value) {
    _searchService = value;
    notifyListeners();
  }

  set searchFocusNode(FocusNode value) {
    _searchFocusNode = value;
    notifyListeners();
  }

  set searchController(TextEditingController value) {
    _searchController = value;
    notifyListeners();
  }

  init() {}

  ///init search with debouncer to wait for the user input
  void initSearch() {
    searchController.addListener(() => debouncer.value = searchController.text);
    // debouncer.values.listen((search) => submitSearch(search));
    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus) {
        clearSearch();
      }
      notifyListeners();
    });
    scrollController.addListener(() {
      notifyListeners();
    });
  }

  ///Send the user search to the api and wait for the answer
  submitSearch(String search) async {
    if (search.isNotEmpty || search != "") {
      this.search = search;
      List<Experience> response = await searchService.search(search, {}, 1);
      temp.add(response);
      _list = response;
        } else {
      _list.clear();
      temp.stream.drain();
      notifyListeners();
    }
  }

  ///clean the search
  void clearSearch() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    _list.clear();
    temp.stream.drain();
  }
}

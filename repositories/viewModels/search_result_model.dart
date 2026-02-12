import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/search.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/search_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';

class SearchResultModel extends BaseModel {
  late Search _search;
  final SearchService _searchService;
  List<Experience> _list = [];
  bool _showOurBottomSheet = false;
  String searchQueryValue = '';
  late HomeModel homeModel;
  late User user;
  final ApplicationApi _applicationApi;

  Search get search => _search;
  StreamController<List<Experience>> _temp = StreamController.broadcast();

  StreamController<List<Experience>> get temp => _temp;

  SearchService get searchService => _searchService;

  List<Experience> get list => _list;

  bool get showOurBottomSheet => _showOurBottomSheet;

  set showOurBottomSheet(bool value) {
    _showOurBottomSheet = value;
    notifyListeners();
  }

  set list(List<Experience> value) {
    _list = value;
    notifyListeners();
  }

  set temp(StreamController<List<Experience>> value) {
    _temp = value;
    notifyListeners();
  }

  set search(Search value) {
    _search = value;
    notifyListeners();
  }

  bool show = false;



  List<Experience> _response = [];

  List<Experience> get response => _response;

  set response(List<Experience> value) {
    _response = value;
    notifyListeners();
  }

  void init(BuildContext context) async {
    response = await searchService.search(searchQueryValue, _search.filterFromFilterView, 1);
    if (response != []) {
      temp.add(response);
    } else {
      temp.add([]);
    }
    notifyListeners();
  }

  void clearExperiences() {
    _list.clear();
    temp.stream.drain();
  }

  void showBottom() {
    _showOurBottomSheet = true;
    notifyListeners();
  }

  void hideOurBottomSheet() {
    _showOurBottomSheet = false;
    notifyListeners();
  }

  Future<ApplicationApiResponse> hideExperience(int id) async {
    setState(ViewState.Busy);
    ApplicationApiResponse result = await _applicationApi.hideExperience(id);
    setState(ViewState.Idle);
    if (result.result) {
      response.removeWhere((element) => element.experienceId == id);
      list.clear();
      temp.stream.drain();
      temp.add(response);
    }
    return result;
  }

  SearchResultModel(this._applicationApi, this._searchService);
}

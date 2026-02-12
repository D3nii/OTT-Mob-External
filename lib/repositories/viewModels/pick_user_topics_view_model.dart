import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class PickUserTopicsViewModel extends BaseModel {
  late ProfileService _profileService;
  ScrollController _scrollController = ScrollController();
  late ApplicationApi _applicationApi;
  bool _seeMoreTopicsEnabled = true;
  int _topicsPageSize = 0;
  List<Topic> _topicsList = [];
  bool _nextTopicsButtonEnabled = false;
  int _selectedTopicsCount = 0;
  bool _loadingMore = false;
  bool _savingUserSelectedTopics = false;

  ProfileService get profileService => _profileService;

  ScrollController get scrollController => _scrollController;

  bool get seeMoreTopicsEnabled => _seeMoreTopicsEnabled;

  bool get loadingMore => _loadingMore;

  bool get nextTopicsButtonEnabled => _nextTopicsButtonEnabled;

  bool get savingUserSelectedTopics => _savingUserSelectedTopics;

  set nextTopicsButtonEnabled(bool nextTopicsButtonEnabled) {
    if (nextTopicsButtonEnabled != _nextTopicsButtonEnabled) {
      _nextTopicsButtonEnabled = nextTopicsButtonEnabled;
      notifyListeners();
    }
  }

  set applicationApi(ApplicationApi value) {
    _applicationApi = value;
  }

  List<Topic> get topicsList => _topicsList;

  set profileService(ProfileService value) {
    _profileService = value;
    notifyListeners();
  }

  requestTopics() async {
    _topicsPageSize = 50;
    _topicsList = await _applicationApi.getTopics(resultsPerPage: _topicsPageSize, token: '');
    notifyListeners();
  }

  initState() {
    requestTopics();
  }

  toggleTopicSelection(int id) {
    Topic selectedTopic = topicsList.firstWhere((element) => element.id == id);
    selectedTopic.selected = !selectedTopic.selected;
    _selectedTopicsCount += !selectedTopic.selected ? -1 : 1;
    nextTopicsButtonEnabled = _selectedTopicsCount >= 3;
    notifyListeners();
  }

  requestMoreTopics() async {
    _loadingMore = true;
    notifyListeners();
    _topicsPageSize += 1;
    double currentMaxExtent = _scrollController.position.maxScrollExtent;
    int previousCount = topicsList.length;
    topicsList.addAll(await _applicationApi.getTopics(resultsPerPage: _topicsPageSize, token: ''));
    _seeMoreTopicsEnabled = previousCount != topicsList.length;
    notifyListeners();
    Timer(
      Duration(seconds: 1),
      () {
        _scrollController.animateTo(currentMaxExtent + 150, duration: Duration(milliseconds: 500), curve: Curves.ease);
        _loadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<bool> saveUserSelectedTopics() async {
    _savingUserSelectedTopics = true;
    notifyListeners();
    bool result =
        await _profileService.saveUserTopics(topicsList.where((element) => element.selected).map((e) => e.id).toList());

    if (!result) {
      _savingUserSelectedTopics = false;
      notifyListeners();
    }

    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:rxdart/rxdart.dart';

class ProfileService {
  final _log = Logger('ProfileService');

  late ApplicationApi _applicationApi;
  late BaseResponse<User> _userResponse;
  late StreamController<BaseResponse<User>> _userResponseStreamController;
  late StreamController<User> _userStreamController;
  late User _user;

  User get user => _user;

  Stream<User> get userStream {
    return _userStreamController.stream;
  }

  BaseResponse<User> get userResponse => _userResponse;

  Stream<BaseResponse<User>> get userResponseStream {
    return _userResponseStreamController.stream;
  }

  ProfileService(ApplicationApi applicationApi) {
    _applicationApi = applicationApi;
    _userStreamController = BehaviorSubject<User>();
    _userResponseStreamController = BehaviorSubject<BaseResponse<User>>();
    _handleUser(User.initial());
  }

  dispose() {}

  Stream<BaseResponse<User>> getProfileInfo() {
    _log.info('Requesting user profile information...');
    _applicationApi.getUserProfileInfo().then((user) {
      if (user != null) {
        _log.info('Got user profile: ${user.firstName} ${user.lastName}');
        _handleUser(user);
      } else {
        _log.warning('User profile not found: null response');
      }
    }).catchError((error) {
      _log.severe('Failed to fetch user profile: ${error.toString()}');
    });
    return _userResponseStreamController.stream;
  }

  void _handleUser(User user) {
    String status = SUCCESS;
    _user = user;
    _userResponse = BaseResponse(_user, status);
    _log.info('Processing user profile data...');
    _log.info('User country code: "${user.country}"');
    _userStreamController.add(_user);
    _userResponseStreamController.add(_userResponse);
    _log.info('Sent user profile data to streams');
  }

  Future<BaseResponse<User>> putProfileInfo(Map<String, String> data) async {
    Future<BaseResponse<User>> future = _applicationApi.updateUserProfile(data);
    future.then((response) => _handleUser(response.data));
    return future;
  }

  Future<User> putUpdatedPassword(String newPassword, {String? oldPassword}) async {
    var future = _applicationApi.updateUserPassword(newPassword, oldPassword: oldPassword);
    future.then(_handleUser);
    return future;
  }

  Future<bool> saveUserTopics(List<int> list) async {
    var profile = {'topics': list};
    BaseResponse<User> response = await _applicationApi.updateUserProfile(profile);
    if (response.responseStatus == SUCCESS) {
      _applicationApi.updateContext(pickTopics: false);
    }
    return response.responseStatus == SUCCESS;
  }

  Future<bool> deleteAccount() async {
    return _applicationApi.deleteAccount().then((response) => response.responseStatus == SUCCESS);
  }
}

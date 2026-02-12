import 'dart:async';

import 'package:http/http.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/api_one_two_trail.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';

class AuthenticationService {
  late ApplicationApi _applicationApi;
  late ApiProxy _apiProxy;
  final StreamController<User> _userController = StreamController<User>();
  String errorMessage = "";

  Stream<User> get user => _userController.stream;

  AuthenticationService(this._applicationApi, this._apiProxy);

  Future<ApplicationApiResponse> signInWithUserNameAndPassword(String userName, String password) async {
    var response = await _applicationApi.signInWithEmailAndPasswordProxy(userName, password);
    if (response.responseObject != null && response.responseObject is User) {
      _userController.add(response.responseObject as User);
    }
    return response;
  }

  Future<bool> signInWithFacebook() async {
    var fetchedUser = await _apiProxy.signInWithFacebook();
    var hasUser = fetchedUser != null;
    if (hasUser) {
      _userController.add(fetchedUser);
    }
    return hasUser;
  }

  Future<bool> signUp(
      String firstName, String lastName, String email, String password, String countryCode) async {
    var fetchUser = await _apiProxy.signUp(firstName, lastName, email, password, countryCode);
    var hasUser = fetchUser != null;
    errorMessage = _apiProxy.lastErrorMessage;
    return hasUser;
  }

  Future<bool> signInWithApple(String jwt, String userId, String code) async {
    var fetchedUser = await _apiProxy.signInWithApple(jwt, userId, code);
    var hasUser = fetchedUser != null;
    if (hasUser) {
      _userController.add(fetchedUser);
    }
    return hasUser;
  }

  Future<bool> validateEmail(String email) async {
    return await _apiProxy.validateEmail(email);
  }

  Future<ApplicationApiResponse<void>> sendResetPasswordEmail(String email) async {
    return await _apiProxy.sendResetPasswordEmail(email);
  }

  void signOut() {
    _applicationApi.updateContext(token: '');
  }

  Future<Response> resendVerificationEmail(String email) {
    return _applicationApi.sendVerificationEmail(email);
  }
}

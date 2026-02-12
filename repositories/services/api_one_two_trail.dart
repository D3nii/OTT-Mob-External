import 'dart:async';
import 'dart:convert' as JSON;
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/services/crash_reporter.dart';

class ApiProxy {
  late ApplicationApi _applicationApi;
  String lastErrorMessage = "";

  ApiProxy(this._applicationApi);

  Future<User?> signUp(
      String firstName, String lastName, String email, String password, String countryCode) async {
    try {
      var response = await _applicationApi.signUp(firstName, lastName, email, password, countryCode);

      lastErrorMessage = response.statusCode.toString() + " - " + response.body;
      if (response.statusCode != 200) {
        return null;
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        // _apiSource.updateToken(data['token']);
        return User(
          id: 0,
          email: email,
          firstName: firstName,
          lastName: lastName,
          isLogged: true,
          trails: [],
          pickTopics: false,
          password: false,
          phoneNumber: '',
          country: countryCode,
          avatar: '',
          selectCountry: data['select_country'] ?? true,
          visitedExperiences: []
        );
      }
    } catch (e, stackTrace) {
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to sign up user',
        attributes: {
          'email': email,
          'country_code': countryCode,
        },
      );
      return null;
    }
  }

  String hasPassword(String password) {
    var bytes = utf8.encode("$password"); // data being hashed
    var digest = sha256.convert(bytes);
    return "$digest";
  }

  Future<User?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email'],
    );
    if (result.status != LoginStatus.success) {
      return null;
    }
    var facebookUser = await FacebookAuth.instance.getUserData();
    var response = await _applicationApi.signInWithFacebook(result.accessToken?.tokenString ?? '');
    if (response.statusCode != 200) {
      return null;
    }
    var oneTwoTrailUser = JSON.jsonDecode(response.body) as Map<String, dynamic>;
    _applicationApi.updateContext(
      token: oneTwoTrailUser['token'],
      pickTopics: oneTwoTrailUser['pick_topics'],
      isAdmin: oneTwoTrailUser['is_admin'],
    );
    return User(
      id: 0,
      email: facebookUser['email'] as String,
      firstName: facebookUser['name'] as String,
      lastName: '',
      isLogged: true,
      trails: [],
      pickTopics: oneTwoTrailUser['pick_topics'] ?? false,
      password: false,
      phoneNumber: '',
      country: '',
      avatar: '',
      selectCountry: oneTwoTrailUser['select_country'] ?? true,
      visitedExperiences: []
    );
  }

  Future<ApplicationApiResponse<void>> checkCodeInApi(String token, String password, String passwordConfirmation) async {
    //go to the api and ask if the code is correct
    try {
      var response = await _applicationApi.checkCodeInApi(token, password, passwordConfirmation);
      if (response.statusCode == 400 || response.statusCode == 500 || response.statusCode == 422) {
        return ApplicationApiResponse<void>(
            result: false, responseBody: response.reasonPhrase ?? '', statusCode: response.statusCode, responseObject: null);
      } else {
        return ApplicationApiResponse<void>(result: true, responseBody: response.body, statusCode: response.statusCode, responseObject: null);
      }
    } on Exception catch (error) {
      return ApplicationApiResponse<void>(result: true, responseBody: error.toString(), statusCode: 404, responseObject: null);
    } catch (e) {
      return ApplicationApiResponse<void>(result: true, responseBody: e.toString(), statusCode: 404, responseObject: null);
    }
  }

  Future<bool> logOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      return Future.value(true);
    } on Exception {
      return Future.value(false);
    } catch (exception) {
      return Future.value(false);
    }
  }

  Future<ApplicationApiResponse<void>> sendResetPasswordEmail(String email) async {
    try {
      var response = await _applicationApi.sendResetPasswordEmail(email);
      if (response.statusCode == 400 ||
          response.statusCode == 500 ||
          response.statusCode == 422 ||
          response.statusCode > 300) {
        return ApplicationApiResponse<void>(statusCode: response.statusCode, result: false, responseBody: response.body, responseObject: null);
      } else {
        return ApplicationApiResponse<void>(statusCode: response.statusCode, result: true, responseBody: response.body, responseObject: null);
      }
    } on Exception catch (error) {
      throw StateError("Something Went Wrong requesting the reset password: $error");
    }
  }

  Future<bool> validateEmail(String email) async {
    try {
      var response = await _applicationApi.validateEmail(email);

      if (response.statusCode == 400 ||
          response.statusCode == 500 ||
          response.statusCode == 422 ||
          response.statusCode > 300) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e, stackTrace) {
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to validate email',
        attributes: {
          'email': email,
        },
      );
      return true;
    }
  }

  Future<User?> signInWithApple(String jwt, String userId, String code) async {
    var response = await _applicationApi.signInWithApple(jwt, userId, code);
    if (response.statusCode != 200) {
      return null;
    } else {
      var parse = JSON.jsonDecode(response.body) as Map<String, dynamic>;
      _applicationApi.updateContext(
        token: parse['token'],
        pickTopics: parse['pick_topics'],
        isAdmin: parse['is_admin'],
      );
      User userFromApi = User(
        id: 0,
        email: '',
        firstName: '',
        lastName: '',
        isLogged: true,
        trails: [],
        pickTopics: parse['pick_topics'] ?? false,
        password: false,
        phoneNumber: '',
        country: '',
        avatar: '',
        selectCountry: parse['select_country'] ?? true,
        visitedExperiences: []
      );
      return userFromApi;
    }
  }
}

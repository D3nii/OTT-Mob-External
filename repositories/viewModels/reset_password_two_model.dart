import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/api_one_two_trail.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class ResetPasswordTwoModel extends BaseModel {
  bool _passwordLengthValid = false;
  bool _passwordCapitalLetterValid = false;
  bool _passwordNumberValid = false;
  bool _passwordsMatch = false;
  bool _nextPasswordButtonEnabled = false;
  String _token;

  FocusNode _passwordFocusNode = new FocusNode();
  FocusNode _passwordConfirmationFocusNode = new FocusNode();
  TextEditingController _passwordTextController = new TextEditingController();
  TextEditingController _confirmPasswordTextController = new TextEditingController();
  bool _changeVisionOfPasswordText = true;
  bool _changeVisionOfPasswordConfirmText = true;

  ResetPasswordTwoModel(this._apiOneTwoTrail, this._token);

  ApiProxy _apiOneTwoTrail;

  FocusNode get passwordConfirmationFocusNode => _passwordConfirmationFocusNode;

  FocusNode get passwordFocusNode => _passwordFocusNode;

  TextEditingController get confirmPasswordTextController => _confirmPasswordTextController;

  TextEditingController get passwordTextController => _passwordTextController;

  bool get passwordCapitalLetterValid => _passwordCapitalLetterValid;

  bool get passwordNumberValid => _passwordNumberValid;

  bool get passwordLengthValid => _passwordLengthValid;

  bool get nextPasswordButtonEnabled => _nextPasswordButtonEnabled;

  bool get passwordsMatch => _passwordsMatch;

  String get token => _token;

  bool get changeVisionOfPasswordConfirmText => _changeVisionOfPasswordConfirmText;

  bool get changeVisionOfPasswordText => _changeVisionOfPasswordText;

  set changeVisionOfPasswordText(bool value) {
    _changeVisionOfPasswordText = value;
    notifyListeners();
  }

  set changeVisionOfPasswordConfirmText(bool value) {
    _changeVisionOfPasswordConfirmText = value;
    notifyListeners();
  }

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  set passwordsMatch(bool value) {
    _passwordsMatch = value;
    notifyListeners();
  }

  set nextPasswordButtonEnabled(bool nextPasswordButtonEnabled) {
    if (nextPasswordButtonEnabled != _nextPasswordButtonEnabled) {
      _nextPasswordButtonEnabled = nextPasswordButtonEnabled;
      notifyListeners();
    }
  }

  set passwordLengthValid(bool value) {
    _passwordLengthValid = value;
    notifyListeners();
  }

  set passwordCapitalLetterValid(bool value) {
    _passwordCapitalLetterValid = value;
    notifyListeners();
  }

  set passwordNumberValid(bool value) {
    _passwordNumberValid = value;
    notifyListeners();
  }

  set passwordTextController(TextEditingController value) {
    _passwordTextController = value;
    notifyListeners();
  }

  set confirmPasswordTextController(TextEditingController value) {
    _confirmPasswordTextController = value;
    notifyListeners();
  }

  set passwordFocusNode(FocusNode value) {
    _passwordFocusNode = value;
    notifyListeners();
  }

  set passwordConfirmationFocusNode(FocusNode value) {
    _passwordConfirmationFocusNode = value;
    notifyListeners();
  }

  ///Un-focus all text fields
  void unfocusAllTextFields() {
    passwordFocusNode.unfocus();
    passwordConfirmationFocusNode.unfocus();
  }

  /// triggers password string check, then updates next button state.
  updatePassword() {
    String passwordText = passwordTextController.text;
    passwordLengthValid = passwordText.length >= 6;
    passwordCapitalLetterValid = passwordText.toLowerCase() != passwordText;
    passwordNumberValid = passwordText.contains(new RegExp(r'[0-9]'));

    String passwordConfirmationText = passwordTextController.text;
    if (passwordNumberValid &&
        passwordCapitalLetterValid &&
        passwordLengthValid &&
        passwordTextController.text == confirmPasswordTextController.text) {
      _passwordsMatch = passwordConfirmationText == passwordTextController.text;
    }

    notifyListeners();
  }

  /// triggers password confirmation string check, then updates next button state.
  updateConfirmationPassword() {
    String passwordConfirmationText = confirmPasswordTextController.text;
    if (passwordNumberValid &&
        passwordCapitalLetterValid &&
        passwordLengthValid &&
        passwordTextController.text == confirmPasswordTextController.text) {
      _passwordsMatch = passwordConfirmationText == passwordTextController.text;
    }

    notifyListeners();
  }

  ///Request Reset password
  Future<ApplicationApiResponse> resetPasswordWithCode() async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }
    setState(ViewState.Busy);
    ApplicationApiResponse result =
        await _apiOneTwoTrail.checkCodeInApi(token, passwordTextController.text, confirmPasswordTextController.text);
    unfocusAllTextFields();
    clearAllTextFields();
    passwordsMatch = false;
    setState(ViewState.Idle);
    return result;
  }

  ///clear al text fields
  void clearAllTextFields() {
    passwordTextController.clear();
    confirmPasswordTextController.clear();
  }
}

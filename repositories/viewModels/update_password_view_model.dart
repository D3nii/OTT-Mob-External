import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class UpdatePasswordViewModel extends BaseModel {
  late User _user;
  late AuthenticationService _authenticationService;
  late ProfileService _profileService;
  FocusNode _currentPasswordFocusNode = FocusNode();
  FocusNode _newPasswordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  TextEditingController _newPasswordTextController = TextEditingController();
  TextEditingController _currentPasswordTextController = TextEditingController();
  TextEditingController _confirmPasswordTextController = TextEditingController();
  bool _updateButtonEnabled = false;
  bool _successToastVisible = false;
  bool _passwordLengthValid = false;
  bool _passwordCapitalLetterValid = false;
  bool _passwordNumberValid = false;
  bool _passwordMatchValid = false;

  User get user => _user;

  AuthenticationService get authenticationService => _authenticationService;

  FocusNode get currentPasswordFocusNode => _currentPasswordFocusNode;

  FocusNode get newPasswordFocusNode => _newPasswordFocusNode;

  FocusNode get confirmPasswordFocusNode => _confirmPasswordFocusNode;

  TextEditingController get newPasswordTextController => _newPasswordTextController;

  TextEditingController get currentPasswordTextController => _currentPasswordTextController;

  TextEditingController get confirmPasswordTextController => _confirmPasswordTextController;

  ProfileService get profileService => _profileService;

  bool get updateButtonEnabled => _updateButtonEnabled;

  bool get successToastVisible => _successToastVisible;

  bool get passwordLengthValid => _passwordLengthValid;

  bool get passwordCapitalLetterValid => _passwordCapitalLetterValid;

  bool get passwordNumberValid => _passwordNumberValid;

  bool get passwordMatchValid => _passwordMatchValid;

  set passwordMatchValid(bool passwordMatchValid) {
    if (passwordMatchValid != _passwordMatchValid) {
      _passwordMatchValid = passwordMatchValid;
      notifyListeners();
    }
  }

  set passwordLengthValid(bool passwordLengthValid) {
    if (passwordLengthValid != _passwordLengthValid) {
      _passwordLengthValid = passwordLengthValid;
      notifyListeners();
    }
  }

  set passwordCapitalLetterValid(bool passwordCapitalLetterValid) {
    if (passwordCapitalLetterValid != _passwordCapitalLetterValid) {
      _passwordCapitalLetterValid = passwordCapitalLetterValid;
      notifyListeners();
    }
  }

  set passwordNumberValid(bool passwordNumberValid) {
    if (passwordNumberValid != _passwordNumberValid) {
      _passwordNumberValid = passwordNumberValid;
      notifyListeners();
    }
  }

  set successToastVisible(bool value) {
    _successToastVisible = value;
    notifyListeners();
  }

  set updateButtonEnabled(bool value) {
    _updateButtonEnabled = value;
    notifyListeners();
  }

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  set profileService(ProfileService value) {
    _profileService = value;
    notifyListeners();
  }

  set authenticationService(AuthenticationService value) {
    _authenticationService = value;
    notifyListeners();
  }

  set currentPasswordFocusNode(FocusNode focusNode) {
    if (currentPasswordFocusNode != _currentPasswordFocusNode) {
      _currentPasswordFocusNode = currentPasswordFocusNode;
      notifyListeners();
    }
  }

  set newPasswordFocusNode(FocusNode focusNode) {
    if (newPasswordFocusNode != _newPasswordFocusNode) {
      _newPasswordFocusNode = newPasswordFocusNode;
      notifyListeners();
    }
  }

  set confirmPasswordFocusNode(FocusNode focusNode) {
    if (confirmPasswordFocusNode != _confirmPasswordFocusNode) {
      _confirmPasswordFocusNode = confirmPasswordFocusNode;
      notifyListeners();
    }
  }

  set newPasswordTextController(TextEditingController newPasswordTextController) {
    if (newPasswordTextController != _newPasswordTextController) {
      _newPasswordTextController = newPasswordTextController;
      notifyListeners();
    }
  }

  set confirmPasswordTextController(TextEditingController confirmPasswordTextController) {
    if (confirmPasswordTextController != _confirmPasswordTextController) {
      _confirmPasswordTextController = confirmPasswordTextController;
      notifyListeners();
    }
  }

  unfocusAllTextFields() {
    currentPasswordFocusNode.unfocus();
    newPasswordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();
  }

  updatePassword(BuildContext context) async {
    String? oldPassword;
    if (user.password) {
      oldPassword = currentPasswordTextController.text;
    }
    User responseUser =
        await profileService.putUpdatedPassword(newPasswordTextController.text, oldPassword: oldPassword);
    if (responseUser.email.isNotEmpty) {
      Navigator.of(context).pop();
    } else {
      showErrorMessage();
    }
  }

  showErrorMessage() async {
    _successToastVisible = true;
    notifyListeners();
    Future.delayed(Duration(seconds: 2)).then((value) {
      _successToastVisible = false;
      notifyListeners();
    });
  }

  updateValidations() {
    String newPasswordText = newPasswordTextController.text;
    String newPasswordConfirmationText = confirmPasswordTextController.text;

    passwordLengthValid = newPasswordText.length >= 8;
    passwordCapitalLetterValid = newPasswordText.toLowerCase() != newPasswordText;
    passwordNumberValid = newPasswordText.contains(new RegExp(r'[0-9]'));
    passwordMatchValid = newPasswordText == newPasswordConfirmationText;

    updateButtonEnabled =
        passwordLengthValid && passwordCapitalLetterValid && passwordNumberValid && passwordMatchValid;

    if (user.password) {
      String currentPassword = currentPasswordTextController.text;
      updateButtonEnabled = currentPassword.length >= 8;
    }
  }

  @override
  void dispose() {
    // Dispose of focus nodes and text controllers
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _newPasswordTextController.dispose();
    _currentPasswordTextController.dispose();
    _confirmPasswordTextController.dispose();
    super.dispose();
  }
}

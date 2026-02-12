import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/enums/enum_responses_login.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/country.dart';
import 'package:onetwotrail/repositories/models/register_step.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/services/crash_reporter.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class RegisterPageModel extends BaseModel {
  RegisterStep _registerStep = RegisterStep.initial();
  bool _firstNameValid = false;
  bool _lastNameValid = false;
  bool _emailValid = false;
  bool _countryValid = false;
  bool _emailTaken = false;
  bool _passwordsMatch = false;
  final AuthenticationService _authenticationService;
  bool _nextButtonEnabled = false;
  bool _nextPasswordButtonEnabled = false;
  bool _passwordLengthValid = false;
  bool _passwordCapitalLetterValid = false;
  bool _passwordNumberValid = false;
  bool _termsAndConditionsTicked = false;
  Country? _selectedCountry;

  RegisterPageModel({required AuthenticationService authenticationService}) : _authenticationService = authenticationService;


  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _lastNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _passwordConfirmationTextController = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _passwordConfirmationFocusNode = FocusNode();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  EnumResponsesLogin _validation = EnumResponsesLogin.FIRST_STATE;
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  PageController _pageController = PageController(
    initialPage: 0,
  );

  bool get emailTaken => _emailTaken;

  ScrollController get scrollController => _scrollController;

  FocusNode get firstNameFocusNode => _nameFocusNode;

  FocusNode get lastNameFocusNode => _lastNameFocusNode;

  FocusNode get emailFocusNode => _emailFocusNode;

  FocusNode get passwordFocusNode => _passwordFocusNode;

  FocusNode get passwordConfirmationFocusNode => _passwordConfirmationFocusNode;

  AuthenticationService get authenticationService => _authenticationService;

  bool get nextButtonEnabled => _nextButtonEnabled;

  bool get nextPasswordButtonEnabled => _nextPasswordButtonEnabled;

  bool get passwordLengthValid => _passwordLengthValid;

  bool get passwordCapitalLetterValid => _passwordCapitalLetterValid;

  bool get passwordNumberValid => _passwordNumberValid;

  bool get termsAndConditionsTicked => _termsAndConditionsTicked;

  Country? get selectedCountry => _selectedCountry;

  TextEditingController get firstNameTextController => _nameTextController;

  TextEditingController get lastNameTextController => _lastNameTextController;

  TextEditingController get emailTextController => _emailTextController;

  TextEditingController get passwordTextController => _passwordTextController;

  TextEditingController get passwordConfirmationTextController => _passwordConfirmationTextController;

  get formKey => _formKey;

  EnumResponsesLogin get validation => _validation;

  set formKey(value) {
    formKey = value;
    notifyListeners();
  }

  set firstNameFocusNode(FocusNode focusNode) {
    if (firstNameFocusNode != _nameFocusNode) {
      _nameFocusNode = firstNameFocusNode;
      notifyListeners();
    }
  }

  set scrollController(ScrollController scrollController) {
    if (scrollController != _scrollController) {
      _scrollController = scrollController;
      notifyListeners();
    }
  }

  set lastNameFocusNode(FocusNode focusNode) {
    if (lastNameFocusNode != _lastNameFocusNode) {
      _lastNameFocusNode = lastNameFocusNode;
      notifyListeners();
    }
  }

  set emailFocusNode(FocusNode focusNode) {
    if (emailFocusNode != _emailFocusNode) {
      _emailFocusNode = emailFocusNode;
      notifyListeners();
    }
  }

  set passwordFocusNode(FocusNode focusNode) {
    if (passwordFocusNode != _passwordFocusNode) {
      _passwordFocusNode = passwordFocusNode;
      notifyListeners();
    }
  }

  set passwordConfirmationFocusNode(FocusNode focusNode) {
    if (passwordConfirmationFocusNode != _passwordConfirmationFocusNode) {
      _passwordConfirmationFocusNode = passwordConfirmationFocusNode;
      notifyListeners();
    }
  }


  set nextButtonEnabled(bool nextButtonEnabled) {
    if (nextButtonEnabled != _nextButtonEnabled) {
      _nextButtonEnabled = nextButtonEnabled;
      notifyListeners();
    }
  }

  set nextPasswordButtonEnabled(bool nextPasswordButtonEnabled) {
    if (nextPasswordButtonEnabled != _nextPasswordButtonEnabled) {
      _nextPasswordButtonEnabled = nextPasswordButtonEnabled;
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

  set termsAndConditionsTicked(bool termsAndConditionsTicked) {
    unfocusAllTextFields();
    if (termsAndConditionsTicked != _termsAndConditionsTicked) {
      _termsAndConditionsTicked = termsAndConditionsTicked;
      notifyListeners();
    }
  }

  set selectedCountry(Country? selectedCountry) {
    if (selectedCountry != _selectedCountry) {
      _selectedCountry = selectedCountry;
      _countryValid = selectedCountry != null;
      notifyListeners();
    }
  }

  set firstNameTextController(TextEditingController nameTextController) {
    if (nameTextController != _nameTextController) {
      _nameTextController = nameTextController;
      notifyListeners();
    }
  }

  set lastNameTextController(TextEditingController lastNameTextController) {
    if (lastNameTextController != _lastNameTextController) {
      _lastNameTextController = lastNameTextController;
      notifyListeners();
    }
  }

  set emailTextController(TextEditingController emailTextController) {
    if (emailTextController != _emailTextController) {
      _emailTextController = emailTextController;
      notifyListeners();
    }
  }

  set passwordTextController(TextEditingController passwordTextController) {
    if (passwordTextController != _passwordTextController) {
      _passwordTextController = passwordTextController;
      notifyListeners();
    }
  }

  set passwordConfirmationTextController(TextEditingController passwordConfirmationTextController) {
    if (passwordConfirmationTextController != _passwordConfirmationTextController) {
      _passwordConfirmationTextController = passwordConfirmationTextController;
      notifyListeners();
    }
  }

  set validation(EnumResponsesLogin value) {
    _validation = value;
    notifyListeners();
  }

  PageController get pageController => _pageController;

  set pageController(PageController value) {
    _pageController = value;
    notifyListeners();
  }

  unfocusAllTextFields() {
    firstNameFocusNode.unfocus();
    lastNameFocusNode.unfocus();
    passwordFocusNode.unfocus();
    passwordConfirmationFocusNode.unfocus();
    emailFocusNode.unfocus();
  }

  updateFirstName() {
    String firstName = firstNameTextController.text;
    _registerStep.firstName = firstName;
    _firstNameValid = firstName.length < 2 ? false : true;
    nextButtonEnabled = _emailValid && _firstNameValid && _lastNameValid && _countryValid;
    notifyListeners();
  }

  updateLastName() {
    String lastName = lastNameTextController.text;
    _registerStep.lastName = lastName;
    _lastNameValid = lastName.length < 2 ? false : true;
    nextButtonEnabled = _emailValid && _firstNameValid && _lastNameValid && _countryValid;
    notifyListeners();
  }

  updateCountry(Country selectedCountry) {
    this.selectedCountry = selectedCountry;
    _countryValid = true;
    nextButtonEnabled = _emailValid && _firstNameValid && _lastNameValid;
    notifyListeners();
  }

  updateEmail() {
    String email = emailTextController.text;
    _registerStep.email = email;
    _emailValid = _isValidEmail(email) ? true : false;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (_emailValid) {
      nextButtonEnabled = false;
      _emailTaken = false;
      _debounce = Timer(const Duration(milliseconds: 300), () async {
        bool isTaken = false;
        try {
          isTaken = await _authenticationService.validateEmail(email);
        } catch (e, stackTrace) {
          CrashReporter.reportError(
            e,
            stackTrace,
            context: 'Failed to validate email during registration',
            attributes: {
              'email': email,
            },
          );
          // If there's an error, assume email is not taken
        }
        _emailTaken = isTaken;
        nextButtonEnabled = _emailValid && _firstNameValid && _lastNameValid && _countryValid && !isTaken;
        notifyListeners();
      });
    } else {
      nextButtonEnabled = _emailValid && _firstNameValid && _lastNameValid && _countryValid;
    }
    notifyListeners();
  }

  updatePassword() {
    String passwordText = passwordTextController.text;
    _registerStep.password = passwordText;
    passwordLengthValid = passwordText.length >= 8;
    passwordCapitalLetterValid = passwordText.toLowerCase() != passwordText;
    passwordNumberValid = passwordText.contains(new RegExp(r'[0-9]'));

    String passwordConfirmationText = passwordConfirmationTextController.text;
    _passwordsMatch = passwordConfirmationText == _registerStep.password;
    nextPasswordButtonEnabled = _passwordsMatch &&
        passwordLengthValid &&
        passwordCapitalLetterValid &&
        passwordNumberValid &&
        termsAndConditionsTicked;

    notifyListeners();
  }

  updateConfirmationPassword() {
    String passwordConfirmationText = passwordConfirmationTextController.text;
    _passwordsMatch = passwordConfirmationText == _registerStep.password;
    nextPasswordButtonEnabled = _passwordsMatch && termsAndConditionsTicked;
    notifyListeners();
  }

  toggleTermsAndConditions() {
    termsAndConditionsTicked = !termsAndConditionsTicked;
    updatePassword();
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  }

  loginWithFacebook() async {
    setState(ViewState.Busy);
    try {
      var success = await _authenticationService.signInWithFacebook();
      return success;
    } finally {
      setState(ViewState.Idle);
    }
  }

  signInWithFacebook() async {
    setState(ViewState.Busy);
    try {
      return await _authenticationService.signInWithFacebook();
    } catch (e, stackTrace) {
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to sign in with Facebook',
      );
      return false;
    } finally {
      setState(ViewState.Idle);
    }
  }

  signInWithApple(String jwt, String userId, String code) async {
    setState(ViewState.Busy);
    try {
      return await _authenticationService.signInWithApple(jwt, userId, code);
    } catch (e, stackTrace) {
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to sign in with Apple',
        attributes: {
          'user_id': userId,
        },
      );
      return false;
    } finally {
      setState(ViewState.Idle);
    }
  }

  Future<bool> signUp(BuildContext context) async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }

    if (selectedCountry == null) {
      validation = EnumResponsesLogin.INVALID;
      return false;
    }

    // We've already checked that selectedCountry is not null above
    String countryCode = selectedCountry!.code;

    setState(ViewState.Busy);
    try {
      var success = await _authenticationService.signUp(
        _registerStep.firstName,
        _registerStep.lastName,
        _registerStep.email,
        _registerStep.password,
        countryCode
      );

      if (!success) {
        validation = EnumResponsesLogin.INVALID;
        return false;
      }
      return true;
    } catch (e, stackTrace) {
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to sign up user',
        attributes: {
          'email': _registerStep.email,
          'country_code': countryCode,
        },
      );
      validation = EnumResponsesLogin.INVALID;
      return false;
    } finally {
      setState(ViewState.Idle);
    }
  }

  backToPageOne(BuildContext context) {
    pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    restartPasswordForm();
  }

  backToPageTwo(BuildContext context) {
    pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    restartPasswordForm();
  }

  restartPasswordForm() {
    passwordTextController.text = "";
    passwordConfirmationTextController.text = "";
    termsAndConditionsTicked = false;
    _registerStep.password = "";
    nextPasswordButtonEnabled = false;
    updatePassword();
    notifyListeners();
  }

  popView(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

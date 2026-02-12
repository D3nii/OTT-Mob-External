import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class ResetPasswordSendEmailViewModel extends BaseModel {
  bool _emailValid = false;
  late AuthenticationService _authenticationService;
  TextEditingController _emailController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();
  Debouncer _debouncer = Debouncer<String>(Duration(milliseconds: 300), initialValue: '');

  TextEditingController get emailController => _emailController;

  FocusNode get emailFocusNode => _emailFocusNode;

  bool get emailValid => _emailValid;

  Debouncer get debouncer => _debouncer;

  AuthenticationService get authenticationService => _authenticationService;

  set authenticationService(AuthenticationService value) {
    _authenticationService = value;
    notifyListeners();
  }

  set debouncer(value) {
    _debouncer = value;
    notifyListeners();
  }

  set emailValid(bool value) {
    _emailValid = value;
    notifyListeners();
  }

  set emailFocusNode(FocusNode value) {
    _emailFocusNode = value;
    notifyListeners();
  }

  set emailController(TextEditingController value) {
    _emailController = value;
    notifyListeners();
  }

  ///Firts method to load data
  init() {
    _emailController.addListener(() {
      notifyListeners();
    });
    _emailFocusNode.addListener(() {
      notifyListeners();
    });
  }

  ///Debounce listener to wait for user inputs
  debounceListener(String text) {
    _emailController.addListener(() => _debouncer.value = _emailController.text);
    _debouncer.values.listen((text) {
      validateEmail(text);
    });
  }

  ///Validate email
  void validateEmail(String text) {
    var email = text;
    bool emailValidCheck =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    emailValid = emailValidCheck;
  }

  ///Request Reset Password
  Future<ApplicationApiResponse> sendRequestResetPassword() async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }
    setState(ViewState.Busy);
    if (emailValid) {
      ApplicationApiResponse result = await authenticationService.sendResetPasswordEmail(emailController.text);
      setState(ViewState.Idle);
      return result;
    } else {
      return ApplicationApiResponse(responseBody: "email is invalid", statusCode: 404, result: false, responseObject: null);
    }
  }
}

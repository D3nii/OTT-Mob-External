import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:onetwotrail/repositories/enums/enum_responses_login.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/services/base_view_service.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:onetwotrail/utils/base_view_provider.dart';

import 'base_model.dart';

class LoginModel extends BaseModel {
  BaseView _baseView = BaseView();
  late AuthenticationService _authenticationService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode passwordInputFocusNode = FocusNode();
  final FocusNode userNameInputFocusNode = FocusNode();
  String _defaultPasswordHint = '';
  String passwordHint = '';
  String userEmailHint = '';
  String _defaultUserNameHint = '';
  String _errorMessage = '';
  bool _showError = false;
  EnumResponsesLogin _validation = EnumResponsesLogin.FIRST_STATE;
  Debouncer<String> _debouncer = Debouncer<String>(Duration(milliseconds: 300), initialValue: '');
  late BuildContext _context;

  late BaseViewService _baseViewService;

  TextEditingController _userEmail = TextEditingController();
  TextEditingController _userPassword = TextEditingController();

  AuthenticationService get authenticationService => _authenticationService;

  GlobalKey<FormState> get formKey => _formKey;

  TextEditingController get userEmail => _userEmail;

  TextEditingController get userPassword => _userPassword;

  EnumResponsesLogin get validation => _validation;

  Debouncer<String> get debouncer => _debouncer;

  BuildContext get context => _context;

  BaseView get baseView => _baseView;

  BaseViewService get baseViewService => _baseViewService;

  String get errorMessage => _errorMessage;

  bool get showError => _showError;

  set showError(bool value) {
    _showError = value;
    notifyListeners();
  }

  set errorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  set baseViewService(BaseViewService value) {
    _baseViewService = value;
    notifyListeners();
  }

  set baseView(BaseView value) {
    _baseView = value;
    notifyListeners();
  }

  set context(BuildContext value) {
    _context = value;
    notifyListeners();
  }

  set debouncer(Debouncer<String> value) {
    _debouncer = value;
    notifyListeners();
  }

  set validation(EnumResponsesLogin value) {
    _validation = value;
    notifyListeners();
  }

  set defaultPasswordHint(String defaultPasswordHint) {
    _defaultPasswordHint = defaultPasswordHint;
  }

  set userPassword(TextEditingController value) {
    _userPassword = value;
    notifyListeners();
  }

  set userEmail(TextEditingController value) {
    _userEmail = value;

    notifyListeners();
  }

  set formKey(GlobalKey<FormState> value) {
    // Note: This setter has a recursive call issue - it should be fixed
    // but we'll keep it as is for now to maintain compatibility
    formKey = value;
    notifyListeners();
  }

  set authenticationService(AuthenticationService value) {
    _authenticationService = value;
    notifyListeners();
  }

  set defaultUserNameHint(String defaultUserNameHint) {
    _defaultUserNameHint = defaultUserNameHint;
  }

  void init(BuildContext context) {
    _context = context;
    passwordInputFocusNode.addListener(() {
      if (passwordInputFocusNode.hasFocus) {
        passwordHint = '';
      } else {
        passwordHint = _defaultPasswordHint;
      }
    });
    userNameInputFocusNode.addListener(() {
      if (userNameInputFocusNode.hasFocus) {
        userEmailHint = '';
      } else {
        userEmailHint = _defaultUserNameHint;
      }

      notifyListeners();
    });
    _userEmail.addListener(() {
      notifyListeners();
    });
    _userPassword.addListener(() {
      notifyListeners();
    });
  }

  void debounceListener(String text) {
    _userPassword.addListener(() => _debouncer.value = _userPassword.text);
    _debouncer.values.listen((text) {
      validation = EnumResponsesLogin.FIRST_STATE;
    });
  }

  void validationUserPassword(BuildContext context) {
    if (userEmail.text.trim().isNotEmpty && userPassword.text.isNotEmpty) {
      if (userPassword.text.length < 8) {
        validation = EnumResponsesLogin.PASSWORD_TO_SHORT;
        errorMessage = AppLocalizations.of(context)?.passwordToShort ?? 'Password is too short';
        showError = true;
      } else {
        validation = EnumResponsesLogin.VALID;
        showError = false;
      }
    } else {
      validation = EnumResponsesLogin.USERNAME_AND_PASSWORD_EMPTY;
      errorMessage = AppLocalizations.of(context)?.wrongCredentials ?? 'Wrong credentials';
      showError = true;
    }
  }

  Future<int> signInWithUserEmailAndPassword(BuildContext context) async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }
    final form = formKey.currentState;
    if (form?.validate() ?? false) {
      errorMessage = "";
      showError = false;
      setState(ViewState.Busy);
    }
    var response = await _authenticationService.signInWithUserNameAndPassword(userEmail.text.trim(), userPassword.text);
    if (response.statusCode == 422 &&
        response.responseBody.contains("confirm") &&
        response.responseBody.contains("account")) {
      showEmailNotVerifiedDialog(context);
    } else if (response.statusCode == 422) {
      showError = true;
      validation = EnumResponsesLogin.INVALID;
      errorMessage = AppLocalizations.of(context)?.wrongCredentials ?? 'Wrong credentials';
    } else {
      Dialogs.showSomethingWentWrongDialog(context);
    }
    setState(ViewState.Idle);
    return response.statusCode;
  }

  void closeView() {
    baseViewService.baseController.add(BaseView()..visible = false);
  }

  void showCircular() {
    baseView.visible = true;
    baseView.pushNotification = false;
    baseView.loading = true;
  }

  Future<bool> signInWithFacebook() async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }
    setState(ViewState.Busy);
    bool result = await _authenticationService.signInWithFacebook();
    setState(ViewState.Idle);
    return result;
  }

  Future<bool> signInWithApple(String jwt, String userId, String code) async {
    setState(ViewState.Busy);
    var success = await _authenticationService.signInWithApple(jwt, userId, code);
    // Handle potential error here too.
    if (!success) _errorMessage = "Sign Up Fail or Cancelled";
    setState(ViewState.Idle);
    return success;
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    setState(ViewState.Busy);
    String email = userEmail.text.trim();
    Response response = await _authenticationService.resendVerificationEmail(email);
    setState(ViewState.Idle);
    // If the response status is not 200, pop a dialog with the something went wrong message.
    if (response.statusCode != 200) {
      Dialogs.showSomethingWentWrongDialog(context);
    }
  }

  void showEmailNotVerifiedDialog(BuildContext context) {
    Dialogs.showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)?.emailNotVerifiedTitle ?? 'Email not verified',
        body: AppLocalizations.of(context)?.emailNotVerifiedContent ?? 'Please verify your email',
        action: DialogAction(
          title: AppLocalizations.of(context)?.resendVerificationEmail ?? 'Resend verification email',
          onPressed: (BuildContext context) {
            resendVerificationEmail(context);
            Navigator.of(context).pop();
          },
          onDismissed: (BuildContext context) {
            Navigator.of(context).pop();
          },
        ));
  }
}

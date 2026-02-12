import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class ResetPasswordModel extends BaseModel {
  TextEditingController _insertCodeController = TextEditingController();
  FocusNode _insertCodeFocusNode = FocusNode();
  bool _codeCheck = false;
  String _error = "";
  late BuildContext _context;

  TextEditingController get insertCodeController => _insertCodeController;

  FocusNode get insertCodeFocusNode => _insertCodeFocusNode;

  bool get codeCheck => _codeCheck;

  String get error => _error;

  BuildContext get context => _context;

  set context(BuildContext value) {
    _context = value;
    notifyListeners();
  }

  set error(String value) {
    _error = value;
    notifyListeners();
  }

  set codeCheck(bool value) {
    _codeCheck = value;
    notifyListeners();
  }

  set insertCodeFocusNode(FocusNode value) {
    _insertCodeFocusNode = value;
    notifyListeners();
  }

  set insertCodeController(TextEditingController value) {
    _insertCodeController = value;
    notifyListeners();
  }

  init() {
    _insertCodeController.addListener(() {
      checkCode(_insertCodeController.text);
    });
  }

  Future<bool> checkCode(String value) async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }

    setState(ViewState.Busy);
    if (value.isNotEmpty) {
      bool result = value.length < 4 ? false : true;
      _codeCheck = result;

      if (result) {
        setState(ViewState.Idle);
        return _codeCheck;
      } else {
        error = AppLocalizations.of(context)?.incorrectCodeText ?? 'Incorrect code';
        setState(ViewState.Idle);
        return _codeCheck;
      }
    }
    setState(ViewState.Idle);
    return false;
  }

  void cleanTextField() {
    insertCodeController.clear();
  }
}

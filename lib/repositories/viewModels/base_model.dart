import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';

class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.Idle;
  bool showErrorStatus = false;
  bool _mounted = true;

  bool get mounted => _mounted;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mounted = false;
  }
}

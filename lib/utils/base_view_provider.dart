class BaseView {
  bool _visible = false;

  bool _loading = false;

  bool _pushNotification = false;

  bool _showBottomSheet = false;

  // ignore: unnecessary_getters_setters
  bool get loading => _loading;

  // ignore: unnecessary_getters_setters
  bool get visible => _visible;

  // ignore: unnecessary_getters_setters
  bool get pushNotification => _pushNotification;

  // ignore: unnecessary_getters_setters
  bool get showBottomSheet => _showBottomSheet;

  // ignore: unnecessary_getters_setters
  set showBottomSheet(bool value) {
    _showBottomSheet = value;
  }

  // ignore: unnecessary_getters_setters
  set loading(bool value) {
    _loading = value;
  }

  // ignore: unnecessary_getters_setters
  set visible(bool value) {
    _visible = value;
  }

  // ignore: unnecessary_getters_setters
  set pushNotification(bool value) {
    _pushNotification = value;
  }
}

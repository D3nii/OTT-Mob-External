import 'package:onetwotrail/repositories/services/base_view_service.dart';
import 'package:onetwotrail/utils/base_view_provider.dart';

import 'base_model.dart';

class BaseModalModel extends BaseModel {
  late BaseViewService _baseViewService;

  BaseViewService get baseViewService => _baseViewService;

  Function(bool) _callback = (visible) {};

  get callback => _callback;

  set baseViewService(BaseViewService value) {
    _baseViewService = value;
    notifyListeners();
  }

  ///update visibility
  changeVisibility(bool visible) {
    BaseView baseView = BaseView();
    baseView.visible = visible;
    _baseViewService.baseController.add(baseView);
  }

  ///Change to loading state
  changeToLoading(bool visible, bool loading, bool pushNotification) {
    BaseView baseView = BaseView();
    baseView.visible = visible;
    baseView.pushNotification = pushNotification;
  }
}

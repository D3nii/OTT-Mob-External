import 'dart:async';

import 'package:onetwotrail/utils/base_view_provider.dart';
import 'package:rxdart/rxdart.dart';

class BaseViewService {
  StreamController<BaseView> baseController = BehaviorSubject();

  Stream<BaseView> get baseView => baseController.stream;

  dispose() {
    baseController.close();
  }

  BaseViewService() {
    baseController.add(BaseView()..visible = false);
  }
}

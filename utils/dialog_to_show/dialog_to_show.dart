import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:provider/provider.dart';

import 'dialog_to_show_model.dart';

class DialogToShow extends StatelessWidget {
  const DialogToShow({Key? key, this.showWidgetDialog}) : super(key: key);

  final bool? showWidgetDialog;

  @override
  Widget build(BuildContext context) {
    return _dialogToShow(context, showWidgetDialog: showWidgetDialog);
  }
}

Widget _dialogToShow(BuildContext context, {bool? showWidgetDialog}) {
  return ChangeNotifierProxyProvider<HomeModel, DialogToShowModel>(
    create: (_) => DialogToShowModel(),
    update: (_, homeModel, model) => (model ?? DialogToShowModel())..init(homeModel),
    child: Consumer<DialogToShowModel>(
      builder: (context, model, _) {
        return Stack(
          children: [model.showTheWidget ? model.widgetToShow : Container()],
        );
      },
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:provider/provider.dart';

abstract class BaseWidget extends StatelessWidget {
  Widget getChild(BuildContext context, BaseWidgetModel baseModel);

  BaseWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<BaseWidgetModel>(
        create: (_) => BaseWidgetModel(),
        child: Consumer<BaseWidgetModel>(builder: (context, model, _) {
          return Stack(
            children: <Widget>[
              getChild(context, model),
              StreamBuilder<Widget?>(
                  stream: model.widgetToShow,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) return snapshot.data!;
                    return Container();
                  })
            ],
          );
        }));
  }
}

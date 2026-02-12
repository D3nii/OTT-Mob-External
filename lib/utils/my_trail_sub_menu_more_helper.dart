import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/constants.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/views/my_trail_sub_menu_more.dart';
import 'package:provider/provider.dart';

class MyTrailSubMenuMoreHelper extends BaseWidgetModel {
  ///Variables

  ///Getters

  ///Setters

  ///First Method to load data
  void init() {}

  Future<void> deployShowDialog(Trail trail, BuildContext context,
      {VoidCallback? delete, Function(ApplicationApiResponse<void>)? trailResult}) async {
    Widget trailActionWidget = Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(0),
      child: Provider<Trail>.value(
        value: trail,
        key: ValueKey(
          trail.id,
        ),
        child: MyTrailSubMenuMore(),
      ),
    );

    //showDialogWidget(trailActionWidget);
    String? result = await showModal<String>(
        context: context,
        builder: (context) => trailActionWidget,
        configuration: FadeScaleTransitionConfiguration(
            barrierColor: Colors.black87,
            transitionDuration: Duration(milliseconds: 300),
            reverseTransitionDuration: Duration(milliseconds: 150)));

    if (result != null && result == Constants.SHOW_EDIT_FORM) {
      // await Future.delayed(Duration(milliseconds: 50));
      await showEditDialog(context, trail, trailResult);
    } else if (result != null && result == Constants.SHOW_DELETE_DIALOG) {
      // await Future.delayed(Duration(milliseconds: 450));
      delete?.call();
    }
    }

  Future<bool?> showEditDialog(BuildContext context, Trail trail, Function(ApplicationApiResponse<void>)? trailResult) async {
    Size mediaQuery = MediaQuery.of(context).size;
    bool? added = await showModal<bool>(
      configuration: FadeScaleTransitionConfiguration(
        barrierColor: Colors.black87,
        transitionDuration: Duration(milliseconds: 175),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Dialog(
            insetPadding: EdgeInsets.all(0),
            backgroundColor: pinkishGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: mediaQuery.height * 0.85,
              width: mediaQuery.width * 0.95,
              child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 10, right: 10, bottom: 5),
                  child: Provider.value(
                      key: ValueKey(trail.id),
                      value: trail,
                      child: ShowDialogEditContent(trail, () {
                        Navigator.pop(context);
                      }, trailResult as dynamic))),
            ),
          ),
        );
      },
    );

    return added;
  }
}

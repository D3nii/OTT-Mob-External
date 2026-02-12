import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/show_dialog_component_delete_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:provider/provider.dart';

class ShowDialogComponentDelete extends StatelessWidget {
  const ShowDialogComponentDelete({
    Key? key,
    required this.close,
    required this.showCircularProgresIndicator,
    required this.closeCircularProgressIndicator,
    required this.showErrorDialog,
  }) : super(key: key);

  final VoidCallback close;
  final VoidCallback showCircularProgresIndicator;
  final VoidCallback closeCircularProgressIndicator;
  final VoidCallback showErrorDialog;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<Trail, TrailService, ShowDialogComponentDeleteViewModel>(
    create: (_) => ShowDialogComponentDeleteViewModel(),
    update: (_, trail, trailService, model) {
      model!.trail = trail;
      model.trailService = trailService;
      model.init();
      return model;
    },
    child: Consumer<ShowDialogComponentDeleteViewModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      return GestureDetector(
        onTap: () {
          close();
        },
        child: Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.8),
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  )),
              height: mediaQuery.height * 0.58,
              width: mediaQuery.width * 0.88,
              child: Padding(
                padding: const EdgeInsets.only(top: 33, left: 35, right: 35, bottom: 42),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(AppLocalizations.of(context)?.trailWillBeDeletedText ?? 'Trail will be deleted',
                          maxLines: 2,
                          maxFontSize: 32,
                          minFontSize: 22,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: tomato)),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.015),
                    Container(
                      child: Text(
                        AppLocalizations.of(context)?.deleteConfirmation ?? 'Are you sure you want to delete this trail?',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
                      ),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.040),
                    Container(
                      height: 50,
                      width: 196,
                      // padding: EdgeInsets.symmetric(
                      //     horizontal: mediaQuery.width * 0.20),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0), side: BorderSide(color: tomato)),
                          backgroundColor: tomato,
                        ),
                        onPressed: () {
                          showErrorDialog();
                        },
                        child: AutoSizeText(
                          AppLocalizations.of(context)?.deleteText ?? 'Delete',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: pinkishGrey),
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.040),
                    InkWell(
                      child: Container(
                        child: Text(
                          AppLocalizations.of(context)?.cancelText ?? 'Cancel',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ),
                      onTap: () {
                        close();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }),
  );
  }
}

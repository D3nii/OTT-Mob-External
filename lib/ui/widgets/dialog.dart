import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';

class DialogAction {
  final String title;
  final Function(BuildContext context) onPressed;
  final Function(BuildContext context)? onDismissed;

  // A constructor for the DialogAction class.
  // The title and onPressed arguments must not be null.
  DialogAction({
    required this.title,
    required this.onPressed,
    this.onDismissed,
  });
}

class Dialogs {
  static void showMessageDialog(BuildContext context, String textResult, VoidCallback okButton) {
    showModal(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
            ),
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Expanded(
                      child: Center(
                        child: Text(
                          textResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30, color: tomato),
                        ),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.20),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: viridian,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      ),
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            AppLocalizations.of(context)?.okText ?? 'OK',
                            maxFontSize: 16,
                            minFontSize: 10,
                            maxLines: 1,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        okButton();
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showErrorMessageDialog(BuildContext context, String textResult, VoidCallback okButton) {
    showModal(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
            ),
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Expanded(
                      child: Center(
                        child: Text(
                          "Error",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30, color: tomato),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Expanded(
                      child: Center(
                        child: Text(
                          textResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16),
                  /*Buttom*/ Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.20),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: viridian,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      ),
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            AppLocalizations.of(context)?.okText ?? 'OK',
                            maxFontSize: 16,
                            minFontSize: 10,
                            maxLines: 1,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        okButton();
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showBodyMessageDialog(
      BuildContext context, Color titleColor, String title, String textResult, VoidCallback okButton) {
    showModal(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
            ),
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Expanded(
                      child: Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: titleColor),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Expanded(
                      child: Center(
                        child: Text(
                          textResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16),
                  /*Buttom*/ Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.20),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: viridian,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      ),
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            AppLocalizations.of(context)?.okText ?? 'OK',
                            maxFontSize: 16,
                            minFontSize: 10,
                            maxLines: 1,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        okButton();
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<T?> showErrorDialog<T>(
      {required BuildContext context, required String title, String? body, DialogAction? action}) {
    return showDialog<T?>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Center(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: tomato),
                          ),
                        ),
                      ),
                      UIHelper.verticalSpace(16),
                      ...[
                      Center(
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              body ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
                            )),
                      )
                    ],
                      UIHelper.verticalSpace(16),
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: viridian,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          ),
                          child: Center(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                action != null ? action.title : AppLocalizations.of(dialogContext)?.okText ?? 'OK',
                                maxLines: 1,
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          onPressed:
                              action != null ? () => action.onPressed(context) : () => Navigator.pop(dialogContext),
                        ),
                      ),
                      UIHelper.verticalSpace(15),
                      ...[
                      // Add a text button.
                      // It contains a text with "Ok".
                      // On tap, it dismisses the dialog.
                      Container(
                        child: Center(
                          child: TextButton(
                            child: Text(
                              AppLocalizations.of(dialogContext)?.dismiss ?? 'Dismiss',
                              style: TextStyle(color: viridian, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            onPressed: () => action?.onDismissed != null
                                ? action!.onDismissed!(dialogContext)
                                : Navigator.pop(dialogContext),
                          ),
                        ),
                      )
                    ]
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  static void showApiErrorDialog(BuildContext dialogContext, ApplicationApiResponse result) {
    var title;
    if (result.statusCode == 700) {
      title = AppLocalizations.of(dialogContext)?.youCantRemoveAllExperiencesText ?? 'You can\'t remove all experiences';
    } else if (result.statusCode == 701) {
      title = AppLocalizations.of(dialogContext)?.trailRemovedText ?? 'Trail removed';
    } else if (result.statusCode == 709) {
      title = AppLocalizations.of(dialogContext)?.passwordWasChangedText ?? 'Password was changed';
    } else {
      title = AppLocalizations.of(dialogContext)?.oopsText ?? 'Oops';
    }
    var body;
    if (result.statusCode == 704) {
      body = AppLocalizations.of(dialogContext)?.somethingWentWrongText ?? 'Something went wrong';
    }
    showErrorDialog(context: dialogContext, title: title, body: body);
  }

  static Future showSomethingWentWrongDialog(BuildContext context) {
    String oopsText = AppLocalizations.of(context)?.oopsText ?? 'Oops';
    String somethingWentWrongText = AppLocalizations.of(context)?.somethingWentWrongText ?? 'Something went wrong';
    return Dialogs.showErrorDialog(context: context, title: oopsText, body: somethingWentWrongText);
  }
}

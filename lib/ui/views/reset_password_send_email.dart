import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';

import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/reset_password_send_email_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/circular_progress_bar.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:provider/provider.dart';



// ignore: must_be_immutable
class ResetPasswordSendEmail extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseWidgetModel) {
    return ChangeNotifierProxyProvider<AuthenticationService, ResetPasswordSendEmailViewModel>(
      create: (_) => ResetPasswordSendEmailViewModel(),
      update: (_, authentication, model) {
        if (model != null) {
          model.authenticationService = authentication;
          model.init();
        }
        return model ?? ResetPasswordSendEmailViewModel();
      },
      child: Consumer<ResetPasswordSendEmailViewModel>(
        builder: (context, model, _) {
          Size mediaQuery = MediaQuery.of(context).size;
          return Scaffold(
            backgroundColor: pinkishGrey,
            body: SingleChildScrollView(
              child: SizedBox(
                height: mediaQuery.height,
                width: mediaQuery.width,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: mediaQuery.width * 0.10,
                    right: mediaQuery.width * 0.10,
                    top: mediaQuery.width * 0.069,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UIHelper.verticalSpace(mediaQuery.height * 0.06),
                      /*AppBar*/ Container(
                        height: mediaQuery.height * 0.025,
                        width: double.infinity,
                        child: InkWell(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Transform.rotate(
                                    angle: pi,
                                    child: Image.asset(
                                      "assets/icons/00AtomsBtnArrow.png",
                                      color: tealish,
                                    ),
                                  )),
                              UIHelper.horizontalSpace(mediaQuery.width * 0.03),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: AutoSizeText(
                                  AppLocalizations.of(context)?.backText ?? "Back",
                                  maxFontSize: 16,
                                  minFontSize: 12,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      UIHelper.verticalSpace(mediaQuery.height * 0.062),
                      AutoSizeText(
                        AppLocalizations.of(context)?.enterYourEmailText ?? "Enter your email",
                        minFontSize: 32,
                        maxFontSize: 42,
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: tealish),
                      ),
                      UIHelper.verticalSpace(mediaQuery.height * 0.01),
                      Text(
                        AppLocalizations.of(context)?.resetPasswordEnterEmail ?? "Reset password enter email",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
                      ),
                      UIHelper.verticalSpace(mediaQuery.height * 0.096),
                      TextFormFieldReset(),
                      UIHelper.verticalSpace(mediaQuery.height * 0.163),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.1321),
                        child: !model.emailValid
                            ? new OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: tealish, width: 2),
                                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 75,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          AppLocalizations.of(context)?.sendEmailText ?? "Send Email",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: tealish,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 25,
                                    //   child: Container(
                                    //     alignment: Alignment.center,
                                    //     child: Image.asset(
                                    //       'assets/icons/00AtomsBtnArrow.png',
                                    //       color: tealish,
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                                onPressed: () {},
                              )
                            : TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: tealish,
                                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 75,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          AppLocalizations.of(context)?.sendEmailText ?? "Send Email",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 25,
                                    //   child: Container(
                                    //     alignment: Alignment.center,
                                    //     child: Image.asset(
                                    //       'assets/icons/00AtomsBtnArrow.png',
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                                onPressed: () async {
                                  baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
                                  ApplicationApiResponse result = await model.sendRequestResetPassword();

                                  if (result.result) {
                                    baseWidgetModel.showOverlayWidget(false, Container());
                                    Navigator.pushNamedAndRemoveUntil(context, "/landing", (r) => false);
                                  } else {
                                    baseWidgetModel.showOverlayWidget(false, Container());
                                    Dialogs.showErrorMessageDialog(
                                      context,
                                      AppLocalizations.of(context)?.resetPasswordErrorText ?? "Reset password error",
                                      () {},
                                    );
                                  }
                                },
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TextFormFieldReset extends StatelessWidget {
  const TextFormFieldReset({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  Size mediaQuery = MediaQuery.of(context).size;
  return Consumer<ResetPasswordSendEmailViewModel>(builder: (context, model, _) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.only(left: mediaQuery.width * 0.054, right: mediaQuery.width * 0.054),
            child: Image.asset(
              "assets/icons/email.png",
              color: model.emailValid ? tealish : pinkishGrey,
            ),
          ),
          Expanded(
            child: Container(
              child: TextField(
                controller: model.emailController,
                focusNode: model.emailFocusNode,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.emailText ?? "Email",
                  hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.black),
                  focusedBorder: InputBorder.none,
                  focusColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.black),
                onChanged: (text) {
                  model.debounceListener(text);
                },
              ),
            ),
          ),
        ],
      ),
    );
  });
}
}

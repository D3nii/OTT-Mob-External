import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';

import 'package:onetwotrail/repositories/viewModels/register_page_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dots_item.dart';
import 'package:onetwotrail/ui/widgets/password_condition_indicator.dart';
import 'package:onetwotrail/ui/widgets/rounded_textfield.dart';
import 'package:provider/provider.dart';



class RegisterStepTwoView extends StatelessWidget {
  const RegisterStepTwoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return Consumer<RegisterPageModel>(
    builder: (context, model, _) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          model.unfocusAllTextFields();
          model.pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: Scaffold(
          backgroundColor: beige,
          body: GestureDetector(
            onTap: () {
              model.unfocusAllTextFields();
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                          height: 40,
                          child: SizedBox(
                            width: 100,
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: TextButton(
                                onPressed: () => model.backToPageOne(context),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage("assets/icons/arrow_back.png"),
                                      size: 17,
                                      color: tealish,
                                    ),
                                    UIHelper.horizontalSpace(6),
                                    Text(
                                      AppLocalizations.of(context)?.backText ?? "Back",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 20,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                            child: Container(
                              height: 104,
                              alignment: Alignment.bottomLeft,
                              child: AutoSizeText(
                                AppLocalizations.of(context)?.selectAPasswordText ?? "Select a password",
                                maxLines: 2,
                                minFontSize: 32,
                                maxFontSize: 42,
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 42,
                                  color: tealish,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: max(MediaQuery.of(context).size.height * 0.05, 30),
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              DotsItem(true, mainColor: tealish),
                              DotsItem(true, mainColor: tealish),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 41,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: RoundedTextfield(
                                    AppLocalizations.of(context)?.passwordText ?? "Password",
                                    AssetImage("assets/icons/lock.png"),
                                    model.passwordTextController,
                                    model.passwordFocusNode,
                                    () {
                                      model.updatePassword();
                                    },
                                    obscured: true,
                                    isEmpty: model.passwordTextController.text.isEmpty,
                                  ),
                                ),
                              ),
                              UIHelper.verticalSpace(10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: RoundedTextfield(
                                    AppLocalizations.of(context)?.confirmPasswordText ?? "Confirm Password",
                                    AssetImage("assets/icons/lock.png"),
                                    model.passwordConfirmationTextController,
                                    model.passwordConfirmationFocusNode,
                                    () {
                                      model.updatePassword();
                                    },
                                    obscured: true,
                                    isEmpty: model.passwordConfirmationTextController.text.isEmpty,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  PasswordConditionIndicator(model.passwordLengthValid),
                                  UIHelper.horizontalSpace(8),
                                  Text(
                                    AppLocalizations.of(context)?.passwordHas8CharactersText ?? "Password has 8 characters",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  PasswordConditionIndicator(model.passwordCapitalLetterValid),
                                  UIHelper.horizontalSpace(8),
                                  Text(
                                    AppLocalizations.of(context)?.includesACapitalLetterText ?? "Includes a capital letter",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  PasswordConditionIndicator(model.passwordNumberValid),
                                  UIHelper.horizontalSpace(8),
                                  Text(
                                    AppLocalizations.of(context)?.includesANumberText ?? "Includes a number",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 0, 40, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Checkbox(
                                activeColor: tealish,
                                checkColor: Colors.white,
                                value: model.termsAndConditionsTicked,
                                onChanged: (bool? value) {
                                  model.toggleTermsAndConditions();
                                },
                              ),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)?.byCheckingThisBoxYouAgreeText ?? "By checking this box you agree",
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            alignment: Alignment.center,
                          ),
                        ),
                        Container(
                          width: 197,
                          height: min(50, MediaQuery.of(context).size.height * 0.08),
                          margin: EdgeInsets.only(left: 48, right: 30),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: model.nextPasswordButtonEnabled ? tealish : beige,
                              //   disabledColor: beige,

                              shape: new RoundedRectangleBorder(
                                side: BorderSide(color: tealish, width: 2, style: BorderStyle.solid),
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  UIHelper.horizontalSpace(32),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppLocalizations.of(context)?.signUp ?? "Sign Up",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: model.nextPasswordButtonEnabled ? Colors.white : tealish,
                                      ),
                                    ),
                                  ),
                                  UIHelper.horizontalSpace(32),
                                ]),
                            onPressed: model.nextPasswordButtonEnabled
                                ? () async {
                                    model.unfocusAllTextFields();
                                    if (await model.signUp(context)) {
                                      model.pageController.animateToPage(
                                        2,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeOut,
                                      );
                                    } else {
                                      // Flushbar(
                                      //   title: "Error",
                                      //   message: model.authenticationService.errorMessage,
                                      //   duration: Duration(seconds: 3),
                                      // )..show(context);
                                      // Using ScaffoldMessenger instead of Flushbar
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(model.authenticationService.errorMessage),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Container(
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}

import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';

import 'package:onetwotrail/repositories/viewModels/register_page_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dots_item.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:onetwotrail/ui/widgets/rounded_country_picker.dart';
import 'package:onetwotrail/ui/widgets/rounded_textfield.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';



class RegisterStepOneView extends StatelessWidget {
  const RegisterStepOneView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  var platform = Theme.of(context).platform;
  return Consumer<RegisterPageModel>(
    builder: (context, model, _) {
      return Scaffold(
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
                              onPressed: () => model.popView(context),
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
                      Container(
                        height: 104,
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                          child: AutoSizeText(
                            AppLocalizations.of(context)?.letsStartText ?? "Let's start",
                            maxLines: 1,
                            minFontSize: 32,
                            maxFontSize: 42,
                            style: TextStyle(
                                fontFamily: "Poppins", fontWeight: FontWeight.w700, fontSize: 42, color: tealish),
                          ),
                        ),
                      ),
                      Container(
                        height: max(MediaQuery.of(context).size.height * 0.03, 30),
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            DotsItem(true, mainColor: tealish),
                            DotsItem(false, mainColor: tealish),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(10),
                      Expanded(
                          flex: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: RoundedTextfield(
                                    AppLocalizations.of(context)?.firstName ?? "First Name",
                                    AssetImage("assets/icons/user.png"),
                                    model.firstNameTextController,
                                    model.firstNameFocusNode,
                                    () {
                                      model.updateFirstName();
                                    },
                                    isEmpty: model.firstNameTextController.text.isEmpty,
                                  ),
                                ),
                              ),
                              UIHelper.verticalSpace(10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: RoundedTextfield(
                                    AppLocalizations.of(context)?.lastNameText ?? "Last Name",
                                    AssetImage("assets/icons/user.png"),
                                    model.lastNameTextController,
                                    model.lastNameFocusNode,
                                    () {
                                      model.updateLastName();
                                    },
                                    isEmpty: model.lastNameTextController.text.isEmpty,
                                  ),
                                ),
                              ),
                              UIHelper.verticalSpace(10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: RoundedTextfield(
                                    AppLocalizations.of(context)?.emailText ?? "Email",
                                    AssetImage("assets/icons/email.png"),
                                    model.emailTextController,
                                    model.emailFocusNode,
                                    () {
                                      model.updateEmail();
                                    },
                                    isEmpty: model.emailTextController.text.isEmpty,
                                    isEmail: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: model.emailTaken
                                    ? Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          AppLocalizations.of(context)?.emailUnavailable ?? "Email unavailable",
                                          style: TextStyle(fontSize: 12, color: Colors.red),
                                          textAlign: TextAlign.start,
                                        ),
                                      )
                                    : Container(),
                              ),
                              UIHelper.verticalSpace(10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Consumer<RegisterPageModel>(
                                    builder: (context, model, _) {
                                      return RoundedCountryPicker();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )),
                      UIHelper.verticalSpace(10),
                      Container(
                        width: 197,
                        height: min(50, MediaQuery.of(context).size.height * 0.08),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: model.nextButtonEnabled ? tealish : beige,
                            //disabledColor: beige,
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
                                  AppLocalizations.of(context)?.nextText ?? "Next",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: model.nextButtonEnabled ? Colors.white : tealish,
                                  ),
                                ),
                              ),
                              UIHelper.horizontalSpace(32),
                            ],
                          ),
                          onPressed: model.nextButtonEnabled
                              ? () {
                                  model.unfocusAllTextFields();
                                  model.pageController.animateToPage(
                                    1,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                  );
                                }
                              : null,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)?.orSignUpWithText ?? "Or sign up with",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 12, fontFamily: "Poppins", color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: platform == TargetPlatform.iOS
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 42,
                                    child: GestureDetector(
                                      onTap: () async {
                                        model.unfocusAllTextFields();
                                        if (await model.signInWithFacebook()) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Image.asset(
                                        "assets/icons/fb-rounded-ios.png",
                                      ),
                                    ),
                                  ),
                                  UIHelper.horizontalSpace(16),
                                  SizedBox(
                                    height: 42,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final credential = await SignInWithApple.getAppleIDCredential(
                                          scopes: [
                                            AppleIDAuthorizationScopes.email,
                                            AppleIDAuthorizationScopes.fullName,
                                          ],
                                        );
                                        final identityToken = credential.identityToken ?? '';
                                        final userIdentifier = credential.userIdentifier ?? '';
                                        final authorizationCode = credential.authorizationCode;
                                        if (await model.signInWithApple(identityToken, userIdentifier, authorizationCode)) {
                                          Navigator.of(context).pop();
                                        } else {
                                          Dialogs.showMessageDialog(
                                              context, AppLocalizations.of(context) == null ? "Something went wrong" : AppLocalizations.of(context)!.somethingWentWrongText, () {});
                                        }
                                      },
                                      child: Image.asset(
                                        "assets/icons/apple_small.png",
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 47,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: ImageIcon(
                                    AssetImage("assets/icons/fb-rounded.png"),
                                    color: facebookColor,
                                    size: 157,
                                  ),
                                  onPressed: () async {
                                    model.unfocusAllTextFields();
                                    if (await model.signInWithFacebook()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                      ),
                    ],
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

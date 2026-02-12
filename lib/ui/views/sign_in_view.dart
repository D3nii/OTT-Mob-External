import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onetwotrail/repositories/enums/enum_responses_login.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/login_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/circular_progress_bar.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInView extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseWidgetModel) {
    var platform = Theme.of(context).platform;
    Size contextSize = MediaQuery.of(context).size;
    return ChangeNotifierProxyProvider<AuthenticationService, LoginModel>(
      create: (_) => LoginModel(),
      update: (_, auth, loginModel) {
        if (loginModel != null) {
          loginModel.authenticationService = auth;
          loginModel.context = context;
          loginModel.init(context);
        }
        return loginModel ?? LoginModel();
      },
      child: Consumer<LoginModel>(builder: (context, model, _) {
        final String defaultPasswordHint = AppLocalizations.of(context)?.passwordText ?? "Password";
        final String defaultEmailHint = AppLocalizations.of(context)?.emailText ?? "Email";
        model.userEmailHint = defaultEmailHint;
        model.passwordHint = defaultPasswordHint;
        var padding = contextSize.width * 0.08;
        return Scaffold(
          backgroundColor: pinkish,
          body: Stack(
            children: <Widget>[
              Image.asset(
                "assets/landing_images/signup_illustration.png",
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              SafeArea(
                child: Container(
                  height: contextSize.height,
                  width: double.infinity,
                  child: Padding(
                      // Set left, right and bottom to padding.
                      padding: EdgeInsets.only(left: padding, right: padding, bottom: padding),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 40,
                              child: SizedBox(
                                width: 100,
                                child: Padding(
                                  padding: EdgeInsets.zero,
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        ImageIcon(
                                          AssetImage("assets/icons/arrow_back.png"),
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                        UIHelper.horizontalSpace(6),
                                        Text(
                                          AppLocalizations.of(context)?.backText ?? "Back",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            UIHelper.verticalSpace(10),
                            Container(
                              height: contextSize.height * 0.074,
                              alignment: Alignment.bottomLeft,
                              child: Image.asset(
                                "assets/icons/logo/logo_green.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                            UIHelper.verticalSpace(MediaQuery.of(context).size.height * 0.04),
                            Container(
                              height: contextSize.height * 0.192,
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(AppLocalizations.of(context)?.welcomeToYourAdventureText ?? "Welcome to your adventure",
                                  maxLines: 2,
                                  minFontSize: 35,
                                  maxFontSize: 40,
                                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            UIHelper.verticalSpace(contextSize.height * 0.059),
                            Form(
                              key: model.formKey,
                              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                                SizedBox(
                                  height: 60,
                                  child: TextFormField(
                                    focusNode: model.userNameInputFocusNode,
                                    textAlign: TextAlign.left,
                                    controller: model.userEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    onFieldSubmitted: (value) {
                                      model.userNameInputFocusNode.unfocus();
                                      FocusScope.of(context).requestFocus(model.passwordInputFocusNode);
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.person,
                                          color: model.userEmail.text != '' ? tealish : pinkishGrey,
                                        ),
                                      ),
                                      hintText: model.userEmailHint,
                                      hintStyle: TextStyle(fontSize: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      filled: true,
                                      contentPadding: EdgeInsets.all(16),
                                      fillColor: Colors.white,
                                    ),
                                    // The validator receives the text that the user has entered.
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)?.enterUserNameErrorText ?? "Please enter your username";
                                      }
                                      return null;
                                    },
                                    onChanged: (text) {
                                      model.showError = false;
                                    },
                                  ),
                                ),
                                model.showError
                                    ? Container(
                                        height: contextSize.height * 0.042,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          model.errorMessage,
                                          style: TextStyle(color: red, fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    : UIHelper.verticalSpace(
                                        16,
                                      ),
                                SizedBox(
                                  height: 60,
                                  child: TextFormField(
                                    obscureText: true,
                                    focusNode: model.passwordInputFocusNode,
                                    onChanged: (text) {
                                      model.debounceListener(text);
                                      model.errorMessage = "";
                                    },
                                    onFieldSubmitted: (value) async {
                                      if (value.length >= 7) {
                                        model.validation = EnumResponsesLogin.VALID;
                                      }
                                      model.passwordInputFocusNode.unfocus();
                                    },
                                    textAlign: TextAlign.left,
                                    controller: model.userPassword,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      prefixIcon: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.lock,
                                          color: model.userPassword.text != '' ? tealish : pinkishGrey,
                                        ),
                                      ),
                                      hintText: model.passwordHint,
                                      hintStyle: TextStyle(fontSize: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      filled: true,
                                      contentPadding: EdgeInsets.all(016),
                                      fillColor: Colors.white,
                                    ),
                                    // The validator receives the text that the user has entered.
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)?.enterUserNameErrorText ?? "Please enter your username";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    child: InkWell(
                                      child: Text(
                                        AppLocalizations.of(context)?.forgotPasswordText ?? "Forgot password?",
                                        style: TextStyle(
                                            decoration: TextDecoration.underline,
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/reset-password');
                                      },
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            UIHelper.verticalSpace(MediaQuery.of(context).size.height * 0.044),
                            SizedBox(
                                height: 49,
                                child: ButtonTheme(
                                  child: Container(
                                    height: 60,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Color(0xffE78DB3),
                                        shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(30.0),
                                        ),
                                      ),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              AppLocalizations.of(context)?.logInText ?? "Log In",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ]),
                                      onPressed: () async {
                                        baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
                                        model.validationUserPassword(context);
                                        int status = await model.signInWithUserEmailAndPassword(context);
                                        if (status == 200) {
                                          return Navigator.popUntil(context, (route) => route.isFirst);
                                        }
                                        baseWidgetModel.showOverlayWidget(false, Container());
                                      },
                                    ),
                                  ),
                                )),
                            UIHelper.verticalSpace(MediaQuery.of(context).size.height * 0.034),
                            Text(
                              AppLocalizations.of(context)?.orSignUpText ?? "Or sign up",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                            UIHelper.verticalSpace(10),
                            platform == TargetPlatform.iOS
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 42,
                                        child: GestureDetector(
                                          onTap: () async {
                                            baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
                                            bool result = await model.signInWithFacebook();
                                            baseWidgetModel.showOverlayWidget(true, Container());
                                            if (result) {
                                              Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                                            } else {
                                              final snackBar = SnackBar(
                                                  content: Text(AppLocalizations.of(context)?.somethingWentWrongText ?? "Something went wrong"));
                                              // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                                            baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
                                            var credential;
                                            try {
                                              credential = await SignInWithApple.getAppleIDCredential(
                                                scopes: [
                                                  AppleIDAuthorizationScopes.email,
                                                  AppleIDAuthorizationScopes.fullName,
                                                ],
                                              );
                                            } catch (e) {}
                                            baseWidgetModel.showOverlayWidget(true, Container());
                                            if (credential != null &&
                                                await model.signInWithApple(credential.identityToken ?? '',
                                                    credential.userIdentifier ?? '', credential.authorizationCode ?? '')) {
                                              Navigator.of(context).popUntil((route) => route.isFirst);
                                            } else {
                                              Dialogs.showMessageDialog(
                                                  context, AppLocalizations.of(context)?.somethingWentWrongText ?? "Something went wrong", () {});
                                            }
                                          },
                                          child: Image.asset(
                                            "assets/icons/apple_small.png",
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : InkWell(
                                    // inkwell color
                                    child: Container(
                                      height: 48,
                                      width: 157,
                                      decoration: BoxDecoration(
                                        color: Color(0xff306ed5),
                                        borderRadius: BorderRadius.all(Radius.circular(32)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.facebookF,
                                            color: Color(0xffe4dcca),
                                          ),
                                          Center(
                                              child: Text(
                                            "Facebook",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xffe4dcca)),
                                          ))
                                        ],
                                      ),
                                    ),
                                    onTap: () async {
                                      baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
                                      await Future.delayed(Duration(milliseconds: 1000));
                                      bool result = await model.signInWithFacebook();
                                      baseWidgetModel.showOverlayWidget(true, Container());
                                      if (result) {
                                        Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                                      } else {
                                        final snackBar = SnackBar(
                                            content: Text(AppLocalizations.of(context)?.somethingWentWrongText ?? "Something went wrong"));
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    },
                                  ),
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

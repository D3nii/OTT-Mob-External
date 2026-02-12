import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';

import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';



class SignUpOrSignInView extends StatelessWidget {
  const SignUpOrSignInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  var contextSize = MediaQuery.of(context).size;
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
          child: Padding(
            padding: EdgeInsets.only(left: padding, right: padding, bottom: padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  height: 40,
                  child: SizedBox(
                    width: 100,
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
                UIHelper.verticalSpace(10),
                Container(
                  height: contextSize.height * 0.074,
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/icons/logo/logo_green.png',
                    fit: BoxFit.fill,
                  ),
                ),
                UIHelper.verticalSpace(contextSize.height * 0.0125),
                Container(
                    height: contextSize.height * 0.20,
                    alignment: Alignment.bottomLeft,
                    child: AutoSizeText(
                      AppLocalizations.of(context)?.welcomeToYourAdventureText ?? "Welcome to your adventure",
                      minFontSize: 28,
                      maxFontSize: 42,
                      maxLines: 3,
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 42),
                    )),
                Expanded(child: Container()),
                ButtonTheme(
                  child: Container(
                    height: 60,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: pigPinkTwo,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/register-view");
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        Flexible(
                          flex: 80,
                          child: AutoSizeText(
                            AppLocalizations.of(context)?.registerUserText ?? "Register User",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: pinkishGrey,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                UIHelper.verticalSpace(contextSize.height * 0.025),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    AppLocalizations.of(context)?.orLoginText ?? "Or Login",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}

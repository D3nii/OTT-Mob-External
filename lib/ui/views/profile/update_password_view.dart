import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';

import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/viewModels/update_password_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/password_condition_indicator.dart';
import 'package:provider/provider.dart';



class UpdatePasswordView extends StatelessWidget {
  const UpdatePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authenticationService = Provider.of<AuthenticationService>(context, listen: false);
    var profileService = Provider.of<ProfileService>(context, listen: false);
    var user = Provider.of<User>(context, listen: false);
    Size mediaQuery = MediaQuery.of(context).size;
    return ChangeNotifierProxyProvider<User, UpdatePasswordViewModel>(
      update: (_, user, model) {
        model!.user = user;
        return model;
      },
      create: (_) => UpdatePasswordViewModel()
        ..profileService = profileService
        ..user = user
        ..authenticationService = authenticationService,
      child: Consumer<UpdatePasswordViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () {
                model.unfocusAllTextFields();
              },
              child: Container(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 104,
                          width: mediaQuery.width,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 104,
                                width: mediaQuery.width,
                                child: Image.asset(
                                  'assets/main_filter/appbar_background_image.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 16, left: 20),
                                  child: Row(children: [
                                    Container(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 5),
                                      child: AutoSizeText(
                                        AppLocalizations.of(context)?.changeMyPasswordText.toUpperCase() ?? "CHANGE MY PASSWORD",
                                        maxLines: 1,
                                        style:
                                            TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: min(mediaQuery.width * 0.1, 40)),
                            color: pinkishGrey,
                            child: ListView(
                              children: [
                                Visibility(child: UIHelper.verticalSpace(12), visible: model.user.password),
                                Visibility(
                                    child: RoundedUpdatePasswordTextfield(
                                      AppLocalizations.of(context)?.currentPasswordText ?? "Current Password",
                                      AssetImage("assets/icons/lock.png"),
                                      model.currentPasswordTextController,
                                      model.currentPasswordFocusNode,
                                      () => model.updateValidations(),
                                      isEmpty: model.currentPasswordTextController.text.isEmpty,
                                      isEmail: false,
                                      obscured: true,
                                    ),
                                    visible: model.user.password),
                                UIHelper.verticalSpace(12),
                                RoundedUpdatePasswordTextfield(
                                  AppLocalizations.of(context)?.newPasswordText ?? "New Password",
                                  AssetImage("assets/icons/lock.png"),
                                  model.newPasswordTextController,
                                  model.newPasswordFocusNode,
                                  () => model.updateValidations(),
                                  isEmpty: model.newPasswordTextController.text.isEmpty,
                                  isEmail: false,
                                  obscured: true,
                                ),
                                UIHelper.verticalSpace(12),
                                RoundedUpdatePasswordTextfield(
                                  AppLocalizations.of(context)?.confirmNewPasswordText ?? "Confirm New Password",
                                  AssetImage("assets/icons/lock.png"),
                                  model.confirmPasswordTextController,
                                  model.confirmPasswordFocusNode,
                                  () => model.updateValidations(),
                                  isEmpty: model.confirmPasswordTextController.text.isEmpty,
                                  isEmail: false,
                                  obscured: true,
                                ),
                                UIHelper.verticalSpace(24),
                                Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        PasswordConditionIndicator(model.passwordLengthValid),
                                        UIHelper.horizontalSpace(8),
                                        AutoSizeText(
                                          AppLocalizations.of(context)?.passwordHas8CharactersText ?? "Password has 8 characters",
                                          maxLines: 1,
                                          minFontSize: 10,
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
                                        AutoSizeText(
                                          AppLocalizations.of(context)?.includesACapitalLetterText ?? "Includes a capital letter",
                                          maxLines: 1,
                                          minFontSize: 10,
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
                                        AutoSizeText(
                                          AppLocalizations.of(context)?.includesANumberText ?? "Includes a number",
                                          maxLines: 1,
                                          minFontSize: 10,
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
                                        PasswordConditionIndicator(model.passwordMatchValid),
                                        UIHelper.horizontalSpace(8),
                                        Flexible(
                                          child: AutoSizeText(
                                            AppLocalizations.of(context)?.newPasswordMatchText ?? "New password and confirmation match",
                                            maxLines: 2,
                                            minFontSize: 10,
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                UIHelper.verticalSpace(24),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 50,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: model.updateButtonEnabled ? tealish : beige,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(color: tealish, width: 2, style: BorderStyle.solid),
                                            borderRadius: BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              UIHelper.horizontalSpace(24),
                                              Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  AppLocalizations.of(context)?.changeMyPasswordText ?? "Change My Password",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: model.updateButtonEnabled ? Colors.white : tealish,
                                                  ),
                                                ),
                                              ),
                                              UIHelper.horizontalSpace(24),
                                            ]),
                                        onPressed:
                                            model.updateButtonEnabled ? () => model.updatePassword(context) : null,
                                      ),
                                    ),
                                  ],
                                ),
                                UIHelper.verticalSpace(24),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    model.successToastVisible
                        ? Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              height: 50,
                              decoration: BoxDecoration(
                                  color: black70Transparent,
                                  border: Border.all(
                                    color: black70Transparent,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(25))),
                              child: Center(
                                widthFactor: 0.8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    UIHelper.horizontalSpace(32),
                                    Flexible(
                                      child: AutoSizeText(
                                        AppLocalizations.of(context)?.yourCurrentPasswordIsIncorrectText ?? "Your current password is incorrect",
                                        maxLines: 2,
                                        minFontSize: 10,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    UIHelper.horizontalSpace(8),
                                    Icon(
                                      Icons.close,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    UIHelper.horizontalSpace(32),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          );
        },
      ));
  }
}

class RoundedUpdatePasswordTextfield extends StatelessWidget {
  final String hintText;
  final AssetImage assetImage;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Function() onChanged;
  final bool obscured;
  final bool isEmpty;
  final bool isEmail;
  final bool allowAllCharacters;
  final bool isPhone;
  final bool enabled;

  const RoundedUpdatePasswordTextfield(
    this.hintText,
    this.assetImage,
    this.textController,
    this.focusNode,
    this.onChanged,
    {Key? key,
    this.obscured = false,
    this.isEmpty = false,
    this.isEmail = false,
    this.allowAllCharacters = false,
    this.isPhone = false,
    this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatePasswordViewModel>(
      builder: (context, model, _) {
        return Material(
          elevation: 0,
          shadowColor: black30Transparent,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            color: Colors.transparent,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  enabled: enabled,
                  focusNode: focusNode,
                  obscureText: obscured,
                  keyboardType: TextInputType.text,
                  controller: textController,
                  onChanged: (_) {
                    onChanged();
                  },
                  onSubmitted: (_) {
                    model.unfocusAllTextFields();
                  },
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.black : pinkishGrey,
                  ),
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: ImageIcon(
                      assetImage,
                      size: 25,
                      color: isEmpty || !enabled ? pinkishGrey : tealish,
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

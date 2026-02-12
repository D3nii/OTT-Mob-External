import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/api_one_two_trail.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/reset_password_two_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/circular_progress_bar.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ResetPasswordViewTwo extends BaseWidget {
  final String url;

  ResetPasswordViewTwo({required this.url, Key? key}) : super(key: key);

  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseWidgetModel) {
    ApiProxy apiOneTwoTrail = Provider.of<ApiProxy>(context, listen: false);
    String token = Uri.tryParse(url)!.queryParameters['reset_password_token'] ?? '';
    return ChangeNotifierProvider<ResetPasswordTwoModel>(
      create: (context) => ResetPasswordTwoModel(apiOneTwoTrail, token),
      child: Consumer<ResetPasswordTwoModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: pinkishGrey,
            body: Container(
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: UIHelper.defaultHorizontalPadding(context)),
                    children: <Widget>[
                      UIHelper.verticalSpace(48),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          children: <Widget>[
                            RotatedBox(
                              quarterTurns: 2,
                              child: Image.asset(
                                'assets/icons/00AtomsBtnArrow.png',
                                color: tealish,
                                height: 20,
                              ),
                            ),
                            UIHelper.horizontalSpace(9),
                            Text(
                              AppLocalizations.of(context)?.backText ?? "Back",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(65),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)?.changePasswordText ?? "Change Password",
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: tealish),
                        ),
                      ),
                      UIHelper.verticalSpace(32),
                      Container(
                        alignment: Alignment.center,
                        child: roundedTextFieldReset(
                            context,
                            AppLocalizations.of(context)?.passwordText ?? "Password",
                            AssetImage("assets/icons/lock.png"),
                            model.passwordTextController,
                            model.passwordFocusNode,
                            () {
                              model.updatePassword();
                            },
                            obscured: model.changeVisionOfPasswordText,
                            changeVision: () {
                              model.changeVisionOfPasswordText = !model.changeVisionOfPasswordText;
                            }),
                      ),
                      UIHelper.verticalSpace(24),
                      Container(
                        alignment: Alignment.center,
                        child: roundedTextFieldReset(
                            context,
                            AppLocalizations.of(context)?.confirmPasswordText ?? "Confirm Password",
                            AssetImage("assets/icons/lock.png"),
                            model.confirmPasswordTextController,
                            model.passwordConfirmationFocusNode,
                            () {
                              model.updatePassword();
                            },
                            obscured: model.changeVisionOfPasswordConfirmText,
                            changeVision: () {
                              model.changeVisionOfPasswordConfirmText = !model.changeVisionOfPasswordConfirmText;
                            }),
                      ),
                      UIHelper.verticalSpace(24),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                passwordConditionIndicatorReset(context, model.passwordLengthValid),
                                UIHelper.horizontalSpace(8),
                                Text(
                                  AppLocalizations.of(context)?.passwordHas8CharactersText ?? "Password has 8 characters",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            UIHelper.verticalSpace(8),
                            Row(
                              children: <Widget>[
                                passwordConditionIndicatorReset(context, model.passwordCapitalLetterValid),
                                UIHelper.horizontalSpace(8),
                                Text(
                                  AppLocalizations.of(context)?.includesACapitalLetterText ?? "Includes a capital letter",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            UIHelper.verticalSpace(8),
                            Row(
                              children: <Widget>[
                                passwordConditionIndicatorReset(context, model.passwordNumberValid),
                                UIHelper.horizontalSpace(8),
                                Text(
                                  AppLocalizations.of(context)?.includesANumberText ?? "Includes a number",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(32),
                      Container(
                        alignment: Alignment.center,
                        child: model.passwordsMatch && model.passwordLengthValid && model.passwordCapitalLetterValid && model.passwordNumberValid
                            ? _SaveChangesButton(baseWidgetModel)
                            : Container(
                                height: 50,
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.17),
                                child: _OpaqueChangeButton()),
                      ),
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

class _SaveChangesButton extends StatelessWidget {
  final BaseWidgetModel baseWidgetModel;

  const _SaveChangesButton(this.baseWidgetModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordTwoModel>(builder: (context, model, _) {
      return Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.0523,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(64)),
            color: tealish,
            border: Border.all(color: tealish, width: 2)),
        child: InkWell(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  flex: 50,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)?.confirm ?? "Confirm",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () async {
            baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
            ApplicationApiResponse result = await model.resetPasswordWithCode();

            if (result.result) {
              baseWidgetModel.showOverlayWidget(false, Container());
              result.statusCode = 710;
              _showModalOfHere(context);
            } else {
              baseWidgetModel.showOverlayWidget(false, Container());
              result.result = false;
              result.statusCode = 404;
              result.responseBody = "test";

              Dialogs.showApiErrorDialog(context, result);
            }
          },
        ),
      );
    });
  }
}

class _OpaqueChangeButton extends StatelessWidget {
  const _OpaqueChangeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordTwoModel>(
      builder: (context, model, _) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkishGrey,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: tealish, width: 3),
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 50,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)?.changeText ?? "Change",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.teal),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        );
      },
    );
  }
}

Widget roundedTextFieldReset(BuildContext context, String hintText, AssetImage assetImage,
    TextEditingController textController, FocusNode focusNode, Function() onChanged,
    {bool obscured = false, VoidCallback? changeVision}) {
  return Consumer<ResetPasswordTwoModel>(
    builder: (context, model, _) {
      return Material(
        elevation: 0,
        shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                focusNode: focusNode,
                obscureText: obscured,
                controller: textController,
                onChanged: (_) {
                  onChanged();
                },
                onSubmitted: (_) {
                  model.unfocusAllTextFields();
                },
                style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w300),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: ImageIcon(
                      assetImage,
                      size: 25,
                      color: pinkishGrey,
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(125, 125, 125, 1),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: obscured
                          ? Icon(
                              Icons.remove_red_eye_outlined,
                              color: silver,
                            )
                          : Icon(
                              Icons.remove_red_eye,
                              color: silver,
                            ),
                      onPressed: () {
                        changeVision?.call();
                      },
                    )),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget passwordConditionIndicatorReset(BuildContext context, bool isActive) {
  return ImageIcon(
    AssetImage(isActive ? "assets/icons/register_ok.png" : "assets/icons/register_cancel.png"),
    size: 16,
    color: isActive ? Color.fromRGBO(0, 192, 173, 1) : Color.fromRGBO(0, 192, 173, 1),
  );
}

void _showModalOfHere(BuildContext context) {
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
                        AppLocalizations.of(context)?.passwordWasChangedText ?? "Password was changed",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30, color: tomato),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    ),
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          AppLocalizations.of(context)?.okText ?? "OK",
                          maxFontSize: 16,
                          minFontSize: 10,
                          maxLines: 1,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/viewModels/reset_password_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:provider/provider.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResetPasswordModel>(
      create: (_) => ResetPasswordModel()
        ..context = context
        ..init(),
      child: Scaffold(
        backgroundColor: pinkishGrey,
        body: const ResetPasswordBody(),
      ),
    );
  }
}

class ResetPasswordBody extends StatelessWidget {
  const ResetPasswordBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordModel>(
      builder: (context, model, _) {
        return SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: UIHelper.defaultHorizontalPadding(context)),
            children: <Widget>[
              UIHelper.verticalSpace(48),
              Container(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/icons/one_two_trail_icon.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
              ),
              UIHelper.verticalSpace(34),
              AutoSizeText(
                AppLocalizations.of(context)?.insertCodeText ?? "Insert Code",
                maxLines: 1,
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: tealish),
              ),
              UIHelper.verticalSpace(24),
              Text(
                AppLocalizations.of(context)?.codeMessageText ?? "Enter the code we sent to your email",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              UIHelper.verticalSpace(72),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                ),
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      focusNode: model.insertCodeFocusNode,
                      obscureText: false,
                      controller: model.insertCodeController,
                      onChanged: (_) {},
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          if (!await model.checkCode(value)) {
                            final snackBar = SnackBar(content: Text(model.error));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        }
                      },
                      style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        prefixIcon: ImageIcon(
                          AssetImage(
                            "assets/icons/lock.png",
                          ),
                          size: 25,
                          color: pinkishGrey,
                        ),
                        hintText: AppLocalizations.of(context)?.insertCodeText ?? "Insert Code",
                        hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.black),
                        border: OutlineInputBorder(
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
              UIHelper.verticalSpace(80),
              model.codeCheck
                  ? Container(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealish,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)?.resetMyPasswordText ?? "Reset My Password",
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: pinkishGrey),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          Navigator.of(context)
                              .pushNamed('/reset_password_view_two', arguments: model.insertCodeController.text);
                          model.cleanTextField();
                          model.codeCheck = false;
                        },
                      ),
                    )
                  : Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(64)),
                          color: Colors.transparent,
                          border: Border.all(color: tealish, width: 2)),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context)?.resetMyPasswordText ?? "Reset My Password",
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: tealish),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              UIHelper.verticalSpace(40),
              Container(
                alignment: Alignment.center,
                child: InkWell(
                  child: Text(
                    AppLocalizations.of(context)?.goToLoginText ?? "Go to Login",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/landing', (Route<dynamic> route) => false);
                  },
                ),
              ),
              UIHelper.verticalSpace(50)
            ],
          ),
        );
      },
    );
  }
}

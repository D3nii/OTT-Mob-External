import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';

import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/viewModels/register_page_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';



class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  final authService = Provider.of<AuthenticationService>(context, listen: false);
  return ChangeNotifierProvider<RegisterPageModel>(
    create: (context) => RegisterPageModel(authenticationService: authService),
    child: Consumer<RegisterPageModel>(
      builder: (context, model, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            // Do nothing, prevent back navigation
          },
          child: Scaffold(
            backgroundColor: turquoise,
            body: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      UIHelper.verticalSpace(16),
                      Container(height: 100),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 90, 0),
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            AppLocalizations.of(context)?.verifyYourEmailText ?? "Verify your email",
                            style: TextStyle(
                                fontFamily: "Poppins", fontWeight: FontWeight.w700, fontSize: 42, color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 100, 0),
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            AppLocalizations.of(context)?.verifyYourEmailAndLogIn ?? "Verify your email and log in",
                            style: TextStyle(
                                fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/icons/notes.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                        child: Container(
                          height: 50,
                          child: TextButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
                                (states) => new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) =>
                                    states.contains(WidgetState.disabled) ? greyColor : pinkish,
                              ),
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ImageIcon(
                                      AssetImage("assets/icons/email.png"),
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  UIHelper.horizontalSpace(24),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      AppLocalizations.of(context)?.verifyYourEmailText ?? "Verify your email",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        wordSpacing: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  UIHelper.horizontalSpace(32),
                                ]),
                            onPressed: () async {
                              // Try to open the default mail app
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: '', // Empty string will open the mail app without a specific recipient
                              );

                              try {
                                if (await canLaunchUrl(emailLaunchUri)) {
                                  await launchUrl(emailLaunchUri);
                                } else {
                                  // If we can't launch the mail app, show a dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Error"),
                                        content: Text("No mail app found"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(AppLocalizations.of(context)?.okText ?? "OK"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } catch (e) {
                                // Handle any exceptions
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error opening mail app"),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          alignment: Alignment.center,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => route.isFirst);
                            },
                            child: Text(
                              AppLocalizations.of(context)?.orGoToLoginText ?? "Or go to login",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  decoration: TextDecoration.underline,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
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
        );
      },
    ),
  );
}
}

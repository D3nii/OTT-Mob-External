import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dots_item.dart';
import 'package:provider/provider.dart';

class OnBoardViewThree extends StatelessWidget {
  const OnBoardViewThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerPageModel>(builder: (context, model, _) {
      return Scaffold(
        backgroundColor: pinkish,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: UIHelper.defaultHorizontalPadding(context)),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 11,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => model.pageController
                            .animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeOut),
                        child: Row(
                          children: <Widget>[
                            RotatedBox(
                              quarterTurns: 2,
                              child: Image.asset(
                                'assets/icons/00AtomsBtnArrow.png',
                                color: Colors.white,
                                height: 20,
                              ),
                            ),
                            UIHelper.horizontalSpace(9),
                            Text(
                              AppLocalizations.of(context)!.backText,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 19,
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.weGotItCovered,
                      maxLines: 2,
                      minFontSize: 35,
                      maxFontSize: 42,
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 11,
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context)!.transformThoseBoardsText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        DotsItem(false),
                        DotsItem(false),
                        DotsItem(true),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 36,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/on_boarding_images/ai.png',
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 13,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        width: 197,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: pinkishGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppLocalizations.of(context)!.letsStartText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      wordSpacing: 2,
                                      color: pinkish,
                                    ),
                                  ),
                                )
                              ]),
                          onPressed: () async {
                            await Provider.of<ApplicationApi>(context, listen: false).updateContext(firstTime: false);
                            Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

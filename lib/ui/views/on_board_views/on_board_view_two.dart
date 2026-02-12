import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dots_item.dart';
import 'package:provider/provider.dart';

class OnBoardViewTwo extends StatelessWidget {
  const OnBoardViewTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerPageModel>(builder: (context, model, _) {
      return Scaffold(
        backgroundColor: tealish,
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
                            .animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeOut),
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
                      AppLocalizations.of(context)!.inspireText,
                      minFontSize: 35,
                      maxFontSize: 42,
                      maxLines: 2,
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: Colors.white),
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
                      AppLocalizations.of(context)!.addAllTheDestinationText,
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
                        DotsItem(true),
                        DotsItem(false),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 36,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/on_boarding_images/inspire.png',
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
                                    AppLocalizations.of(context)!.nextText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      wordSpacing: 2,
                                      color: tealish,
                                    ),
                                  ),
                                ),
                              ]),
                          onPressed: () {
                            model.pageController
                                .animateToPage(2, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/generate_itinerary_from_board_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/dialog_content_view.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GenerateItineraryFromBoard extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseWidgetModel) {
    return ChangeNotifierProxyProvider2<Trail, TrailService, GenerateItineraryFromBoardModel>(
      create: (_) => GenerateItineraryFromBoardModel(),
      update: (_, trail, trailService, model) {
        if (model == null) {
          return GenerateItineraryFromBoardModel()
            ..trail = trail
            ..trailService = trailService
            ..init();
        }
        return model
          ..trail = trail
          ..trailService = trailService
          ..init();
      },
      child: Consumer<GenerateItineraryFromBoardModel>(
        builder: (context, model, _) {
          Size mediaQuery = MediaQuery.of(context).size;
          return Scaffold(
            body: SizedBox(
              height: mediaQuery.height,
              width: mediaQuery.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBarGenerateContainer(),
                  Expanded(
                    child: Container(
                      child: ListView(
                        children: [
                          UIHelper.verticalSpace(mediaQuery.height * 0.07),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.1),
                            child: Column(
                              children: [
                                FirstText(),
                                UIHelper.verticalSpace(mediaQuery.height * 0.07),
                                StartTimeSelecter(),
                                UIHelper.verticalSpace(mediaQuery.height * 0.07),
                                // EndTimeSelecter(),
                                // UIHelper.verticalSpace(
                                //     mediaQuery.height * 0.04),
                                HowManyPeopleText(),
                                UIHelper.verticalSpace(mediaQuery.height * 0.034),
                                HowManyAdults(),
                                UIHelper.verticalSpace(mediaQuery.height * 0.009),
                                HowManyTeens(),
                                UIHelper.verticalSpace(mediaQuery.height * 0.009),
                                HowManyKids(),
                                UIHelper.verticalSpace(mediaQuery.height * 0.054),
                                // WhichOfThisFixedExperiencesText(),
                                // UIHelper.verticalSpace(mediaQuery.height * 0.019),
                                // FixedExperiencesItemsArea(),
                                // UIHelper.verticalSpace(mediaQuery.height * 0.059),
                                _AllButtonGenerate((Widget widget) => baseWidgetModel.showOverlayWidget(true, widget),
                                    () {
                                  baseWidgetModel.showOverlayWidget(false, Container());
                                })
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AllButtonGenerate extends StatelessWidget {
  final Function(Widget widget) showDialog;
  final VoidCallback hideDialog;

  const _AllButtonGenerate(this.showDialog, this.hideDialog, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateItineraryFromBoardModel>(
      builder: (context, model, _) {
        return Center(
          child: Container(
            height: 50,
            width: 196,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: viridian,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
              child: GenerateButtom(),
              onPressed: () async {
                showDialog(DialogContentView());
                ApplicationApiResponse<Itinerary> result = await model.updateItinerary(context);
                if (result.statusCode < 300) {
                  hideDialog();
                  Navigator.pop(context, result.responseObject.id);
                } else {
                  hideDialog();
                  await Future.delayed(Duration(milliseconds: 200));
                  Dialogs.showMessageDialog(
                    context,
                    result.responseBody,
                    () {},
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class GenerateButtom extends StatelessWidget {
  const GenerateButtom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      Flexible(
        flex: 80,
        child: Container(
          // padding: EdgeInsets.only(left: 15),
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context)?.generateText ?? "Generate",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    ]);
  }
}

class FirstText extends StatelessWidget {
  const FirstText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        AppLocalizations.of(context)?.selectYourStartDate ?? "Select your start date",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }
}

class StartTimeSelecter extends StatelessWidget {
  const StartTimeSelecter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateItineraryFromBoardModel>(
      builder: (context, model, _) {
        return Padding(
          padding: EdgeInsets.only(left: 5),
          child: InkWell(
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 25,
                    child: Container(
                      child: Image.asset(
                        "assets/icons/calendar.png",
                        color: tealish,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 50,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat.yMMMd().format(model.startTimeStamp),
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 25,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Transform.rotate(
                        angle: pi / 2,
                        child: Image.asset(
                          'assets/icons/00AtomsBtnArrow.png',
                          color: tealish,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            onTap: () async {
              await showDatePicker(
                      context: context,
                      initialDate: model.startTimeStamp,
                      lastDate: DateTime.now().add(Duration(days: 730)),
                      firstDate: DateTime.now())
                  .then((date) {
                if (date == null) {
                  return;
                }
                model.startTimeStamp = date;
              });
            },
          ),
        );
      },
    );
  }
}

class EndTimeSelecter extends StatelessWidget {
  const EndTimeSelecter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateItineraryFromBoardModel>(
      builder: (context, model, _) {
        return Padding(
          padding: EdgeInsets.only(left: 5),
          child: InkWell(
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 25,
                    child: Container(
                      child: Image.asset(
                        "assets/icons/calendar.png",
                        color: tealish,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 50,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat.yMMMd().format(model.endTimeStamp),
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 25,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Transform.rotate(
                        angle: pi / 2,
                        child: Image.asset(
                          'assets/icons/00AtomsBtnArrow.png',
                          color: tealish,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            onTap: () async {
              await showDatePicker(
                      context: context,
                      initialDate: model.endTimeStamp,
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime.now().add(Duration(days: 730)))
                  .then((date) {
                if (date == null) {
                  return date;
                }

                bool result = model.isValidEndTime(date);
                if (result) {
                  model.endTimeStamp = date;
                  return date;
                } else {
                  Dialogs.showMessageDialog(
                    context,
                    AppLocalizations.of(context)?.youCantSelectADayBeforeTheStartDayText ?? "You can't select a day before the start day",
                    () {},
                  );
                }
              });
            },
          ),
        );
      },
    );
  }
}

class HowManyPeopleText extends StatelessWidget {
  const HowManyPeopleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        AppLocalizations.of(context)?.howManyPeopleText ?? "How many people?",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }
}

class HowManyAdults extends StatelessWidget {
  const HowManyAdults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateItineraryFromBoardModel>(
      builder: (context, model, _) {
        return Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 50,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)?.adultText ?? "Adult",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 50,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)?.eighteenAndOlder ?? "18 and older",
                          style: TextStyle(color: brownishGray, fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${model.adultNumber}",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    InkWell(
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            border: Border.all(color: tealish, width: 2)),
                        child: Image.asset(
                          "assets/icons/icon_minus.png",
                          color: tealish,
                        ),
                      ),
                      onTap: () {
                        model.adultNumber = model.subtract(model.adultNumber, min: 1);
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3)), color: tealish),
                        child: Image.asset(
                          "assets/icons/icon_plus.png",
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        model.adultNumber = model.plus(model.adultNumber);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class HowManyTeens extends StatelessWidget {
  const HowManyTeens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateItineraryFromBoardModel>(
      builder: (context, model, _) {
        return Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 50,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)?.teensText ?? "Teens",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 50,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)?.twelveToSeventeenText ?? "12 to 17",
                          style: TextStyle(color: brownishGray, fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${model.teensNumber}",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    InkWell(
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            border: Border.all(color: tealish, width: 2)),
                        child: Image.asset(
                          "assets/icons/icon_minus.png",
                          color: tealish,
                        ),
                      ),
                      onTap: () {
                        model.teensNumber = model.subtract(model.teensNumber);
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3)), color: tealish),
                        child: Image.asset(
                          "assets/icons/icon_plus.png",
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        model.teensNumber = model.plus(model.teensNumber);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class HowManyKids extends StatelessWidget {
  const HowManyKids({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateItineraryFromBoardModel>(
      builder: (context, model, _) {
        return Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 50,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)?.kidsText ?? "Kids",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 50,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)?.lessThanText ?? "Less than 12",
                          style: TextStyle(color: brownishGray, fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${model.kidsNumber}",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    InkWell(
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            border: Border.all(color: tealish, width: 2)),
                        child: Image.asset(
                          "assets/icons/icon_minus.png",
                          color: tealish,
                        ),
                      ),
                      onTap: () {
                        model.kidsNumber = model.subtract(model.kidsNumber);
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3)), color: tealish),
                        child: Image.asset(
                          "assets/icons/icon_plus.png",
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        model.kidsNumber = model.plus(model.kidsNumber);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class WhichOfThisFixedExperiencesText extends StatelessWidget {
  const WhichOfThisFixedExperiencesText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)?.whichOfTheseFixedExperiencesText ?? "Which of these fixed experiences?",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ),
        UIHelper.verticalSpace(mediaQuery.height * 0.009),
        Container(
          child: Text(
            AppLocalizations.of(context)?.pinnedExperiences ?? "Pinned experiences",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class AppBarGenerateContainer extends StatelessWidget {
  const AppBarGenerateContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
      height: mediaQuery.height * 0.11,
      width: mediaQuery.width,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            height: mediaQuery.height * 0.11,
            width: mediaQuery.width,
            child: Image.asset(
              'assets/main_filter/appbar_background_image.png',
              fit: BoxFit.fill,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 10, top: MediaQuery.of(context).padding.top),
              child: Row(
                children: [
                  Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      highlightColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 10, top: MediaQuery.of(context).padding.top),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)?.createItineraryTitle.toUpperCase() ?? "CREATE ITINERARY",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

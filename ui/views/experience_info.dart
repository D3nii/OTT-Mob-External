import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/anonymous.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/experience_info_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/bottom_buttoms.dart';
import 'package:onetwotrail/ui/widgets/carousel_experiences_images.dart';
import 'package:onetwotrail/ui/widgets/experience_horizontal_list.dart';
import 'package:onetwotrail/ui/widgets/experience_location_map.dart';
import 'package:onetwotrail/ui/widgets/inside_show_modal_bottom_sheet.dart';
import 'package:onetwotrail/utils/expandable_text.dart';
import 'package:onetwotrail/utils/experience_details_helper.dart';
import 'package:onetwotrail/v2/util/string.dart';
import 'package:provider/provider.dart';

class ExperienceInfo extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseModel) {
    Experience experience = Provider.of<Experience>(context);
    ApplicationApi applicationApi = Provider.of<ApplicationApi>(context);
    User user = Provider.of<User>(context);
    return ChangeNotifierProvider<ExperienceInfoModel>(
      create: (context) {
        var model = ExperienceInfoModel(applicationApi, user);
        model.init(experience);
        return model;
      },
      child: Consumer<ExperienceInfoModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: <Widget>[
                AppBarContainer(model.experience),
                model.state == ViewState.Busy
                    ? Expanded(
                        child: Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ))
                    : Expanded(
                        child: model.showError
                            ? Container(
                                height: 200,
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                      text: AppLocalizations.of(context)?.somethingWentWrongRequestText ?? "Something went wrong",
                                      children: [
                                        TextSpan(text: ". "),
                                        TextSpan(
                                          text: AppLocalizations.of(context)?.tryAgain ?? "Try again",
                                          style: TextStyle(decoration: TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => model.init(model.experience),
                                        )
                                      ]),
                                ),
                              )
                            : ContainerOfListViewBody(),
                      )
              ],
            ),
          );
        },
      ),
    );
  }
}

class FirstRow extends StatelessWidget {
  const FirstRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      height: 200,
      width: double.infinity,
      child: Column(children: <Widget>[
        /*top Divider flex 25*/ Flexible(
          flex: 5,
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 30,
                child: Container(),
              ),
              Flexible(
                flex: 40,
                child: Container(
                  child: Divider(
                    thickness: 5,
                  ),
                ),
              ),
              Flexible(
                flex: 30,
                child: Container(),
              )
            ],
          ),
        ),
        /*BigTitle flex 25*/ Flexible(
          flex: 25,
          child: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              AppLocalizations.of(context)?.addToMyTrailsText ?? "Add to my trails",
              maxLines: 1,
              minFontSize: 18,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: tealish),
            ),
          ),
        ),
        /*Small Title flex 25*/ Flexible(
          flex: 25,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)?.selectTrailText ?? "Select trail",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Color(0xff646464)),
            ),
          ),
        ),
        /*Small button  flex 25*/ Flexible(
          flex: 25,
          child: Container(
              child: Row(
            children: <Widget>[
              Expanded(
                flex: 55,
                child: Container(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
                    ),
                    child: Container(
                      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        Expanded(
                          flex: 60,
                          child: Container(
                            alignment: Alignment.center,
                            height: double.infinity,
                            width: double.infinity,
                            child: Text(
                              AppLocalizations.of(context)?.newTrailText ?? "New trail",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 40,
                          child: Container(
                            child: Container(
                              padding: EdgeInsets.only(left: 15),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      height: double.infinity,
                                      width: double.infinity,
                                      alignment: Alignment.bottomRight,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                          border: Border.fromBorderSide(BorderSide.none)),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              Expanded(
                flex: 45,
                child: Container(
                  color: Colors.red,
                ),
              )
            ],
          )),
        )
      ]),
    );
  }
}

class AppBarContainer extends StatelessWidget {
  final Experience experience;

  const AppBarContainer(this.experience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    Size mediaQuery = MediaQuery.of(_context).size;
    return Consumer<ExperienceInfoModel>(builder: (context, model, _) {
      return Container(
          height: 132,
          width: mediaQuery.width,
          child: Stack(
            children: [
              Container(
                width: mediaQuery.width,
                child: Image.asset(
                  'assets/background_images/five_palms.png',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              experience.name.toUpperCase(),
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            Text(
                              "${experience.destinationName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ));
    });
  }
}

class _ReportIssueButton extends StatelessWidget {
  final Experience experience;

  const _ReportIssueButton(this.experience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return Container(
      height: 40,
      width: 160,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(_context)?.reportIssuesText ?? "Report issues",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
              ),
              UIHelper.horizontalSpace(8),
              Container(
                height: 24,
                width: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        height: 16,
                        width: 16,
                      ),
                    ),
                    Align(
                      child: Icon(
                        Icons.info,
                        color: tomato,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
        onPressed: () {
          Navigator.pushNamed(_context, '/reportIssue', arguments: experience);
        },
      ),
    );
  }
}

class ContainerOfListViewBody extends StatelessWidget {
  const ContainerOfListViewBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return Consumer2<ExperienceInfoModel, BaseWidgetModel>(
      builder: (context, model, baseWidgetModel, _) {
        return Stack(
          children: [
            ListView(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 16),
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: CarouselExperiencesImages(model.experience),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ExperienceFacilitiesListView(model.experience),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ExperienceLocationMap(model.experience),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: model.experience.description.isNotEmpty
                      ? Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                capitalizeFirstLetter(AppLocalizations.of(context)?.description ?? "Description"),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ExpandableText(
                              maxLines: 5,
                              textSpan: TextSpan(
                                text: model.experience.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              moreSpan: TextSpan(
                                  text: 'more',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 13)),
                            ),
                          ],
                        )
                      : Container(),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: experienceHorizontalList(
                      context: context,
                      experiences: model.experience.related,
                      experienceNameFontSize: 14,
                      experienceDestinationFontSize: 12,
                      experienceWidthRatio: 0.4,
                      onLongPress: (_context, _experience) => doNothing(),
                      onTap: (_context, _experience) {
                        Navigator.pushNamed(_context, '/experienceInfo', arguments: _experience);
                      },
                      paddingLeft: 16,
                      paddingRight: 16,
                      showAddToTrailButton: false,
                      showMoreOptionsButton: false,
                      spaceBetweenExperiences: 8,
                      title: AppLocalizations.of(context)?.relatedText ?? "Related",
                      titleFontSize: 24,
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: experienceHorizontalList(
                      context: context,
                      experiences: model.experience.nearBy,
                      experienceNameFontSize: 14,
                      experienceDestinationFontSize: 12,
                      experienceWidthRatio: 0.4,
                      onLongPress: (_context, _experience) => doNothing(),
                      onTap: (_context, _experience) {
                        Navigator.pushNamed(_context, '/experienceInfo', arguments: _experience);
                      },
                      paddingLeft: 16,
                      paddingRight: 16,
                      showAddToTrailButton: false,
                      showMoreOptionsButton: false,
                      spaceBetweenExperiences: 8,
                      title: AppLocalizations.of(context)?.nearbyText ?? "Nearby",
                      titleFontSize: 24,
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Container(
                    alignment: Alignment.center,
                    height: 92,
                    width: double.infinity,
                    child: _ReportIssueButton(model.experience),
                  ),
                ),
                Container(
                  height: 128,
                ),
              ],
            ),
            Column(
              children: [
                Expanded(
                  child: Container(),
                ),
                Container(
                  height: 128,
                  width: double.infinity,
                  child: BottomButtoms(model.experience, () async {
                    await showCupertinoModalBottomSheet<String>(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 0, color: Colors.transparent),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      expand: true,
                      context: context,
                      barrierColor: black70Transparent,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Provider.value(
                          key: ValueKey(model.experience.experienceId),
                          value: model.experience,
                          child: InsideShowModalBottomSheet(
                            model.user!,
                            model.experience,
                            () {
                              baseWidgetModel.showOverlayWidget(false, Container());
                            },
                          )),
                    );
                  }),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ThumbUpFingerWithCount extends StatelessWidget {
  final Experience experience;

  const ThumbUpFingerWithCount(this.experience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 5, right: 10),
      child: Container(
        height: 24,
        child: Row(
          children: [
            Container(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/icons/like.png',
                  color: Colors.white,
                )),
            UIHelper.horizontalSpace(8),
            Container(
              child: Text(
                "${experience.likes}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ExperienceFacilitiesListView extends StatelessWidget {
  final Experience experience;

  const ExperienceFacilitiesListView(this.experience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return Consumer<ExperienceInfoModel>(
      builder: (context, model, _) {
        List<ExperienceFeature> features = ExperienceDetailsHelper.getExperienceFeatures(experience);
        return Container(
          height: 80,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: features.length,
            itemBuilder: (context, int index) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 32,
                      child: features[index].image,
                    ),
                    Container(
                      height: 32,
                      width: 72,
                      child: Text(
                        features[index].label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

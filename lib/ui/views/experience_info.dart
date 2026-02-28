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
import 'package:onetwotrail/ui/widgets/cupertino_back_button.dart';
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
            backgroundColor: const Color(0xFFF5F5F7),
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
          height: 160,
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
              Container(
                width: mediaQuery.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoBackButton(
                        label: AppLocalizations.of(context)?.backText ?? "Back",
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              experience.name.toUpperCase(),
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (experience.destinationName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                experience.destinationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ));
    });
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final Clip clipBehavior;

  const _SectionCard({
    Key? key,
    required this.child,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class _ReportIssueButton extends StatelessWidget {
  final Experience experience;

  const _ReportIssueButton(this.experience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFFF5F5F7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.info_outline, color: tomato, size: 18),
          UIHelper.horizontalSpace(8),
          Text(
            AppLocalizations.of(_context)?.reportIssuesText ?? "Report issues",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.pushNamed(_context, '/reportIssue', arguments: experience);
      },
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
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 0.5,
                    child: CarouselExperiencesImages(model.experience),
                  ),
                ),
                const SizedBox(height: 20),
                if (ExperienceDetailsHelper.getExperienceFeatures(model.experience).isNotEmpty)
                  _SectionCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: ExperienceFacilitiesListView(model.experience),
                    ),
                  ),
                if (ExperienceDetailsHelper.getExperienceFeatures(model.experience).isNotEmpty)
                  const SizedBox(height: 20),
                _SectionCard(
                  clipBehavior: Clip.antiAlias,
                  child: ExperienceLocationMap(model.experience),
                ),
                const SizedBox(height: 20),
                if (model.experience.description.isNotEmpty)
                  _SectionCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeFirstLetter(AppLocalizations.of(context)?.description ?? "Description"),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1D1F),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ExpandableText(
                            maxLines: 5,
                            textSpan: TextSpan(
                              text: model.experience.description,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6E6E73),
                                height: 1.4,
                              ),
                            ),
                            moreSpan: const TextSpan(
                              text: 'more',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: tealish,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (model.experience.description.isNotEmpty) const SizedBox(height: 20),
                experienceHorizontalList(
                  context: context,
                  experiences: model.experience.related,
                  experienceNameFontSize: 15,
                  experienceDestinationFontSize: 13,
                  experienceWidthRatio: 0.42,
                  onLongPress: (_context, _experience) => doNothing(),
                  onTap: (_context, _experience) {
                    Navigator.pushNamed(_context, '/experienceInfo', arguments: _experience);
                  },
                  paddingLeft: 0,
                  paddingRight: 16,
                  showAddToTrailButton: false,
                  showMoreOptionsButton: false,
                  spaceBetweenExperiences: 12,
                  title: AppLocalizations.of(context)?.relatedText ?? "Related",
                  titleFontSize: 17,
                  itemBackgroundColor: const Color(0xFFF5F5F7),
                ),
                const SizedBox(height: 32),
                experienceHorizontalList(
                  context: context,
                  experiences: model.experience.nearBy,
                  experienceNameFontSize: 15,
                  experienceDestinationFontSize: 13,
                  experienceWidthRatio: 0.42,
                  onLongPress: (_context, _experience) => doNothing(),
                  onTap: (_context, _experience) {
                    Navigator.pushNamed(_context, '/experienceInfo', arguments: _experience);
                  },
                  paddingLeft: 0,
                  paddingRight: 16,
                  showAddToTrailButton: false,
                  showMoreOptionsButton: false,
                  spaceBetweenExperiences: 12,
                  title: AppLocalizations.of(context)?.nearbyText ?? "Nearby",
                  titleFontSize: 17,
                  itemBackgroundColor: const Color(0xFFF5F5F7),
                ),
                const SizedBox(height: 24),
                Center(
                  child: _ReportIssueButton(model.experience),
                ),
                const SizedBox(height: 88),
              ],
            ),
            Column(
              children: [
                Expanded(
                  child: Container(),
                ),
                Container(
                  height: 88,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
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
        return SizedBox(
          height: 72,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: features.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (context, int index) {
              return SizedBox(
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 28,
                      child: features[index].image,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      features[index].label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6E6E73),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
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

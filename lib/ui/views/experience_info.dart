// ui/views/experience_info.dart
import 'dart:convert';
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
                                      text: AppLocalizations.of(context)
                                              ?.somethingWentWrongRequestText ??
                                          "Something went wrong",
                                      children: [
                                        TextSpan(text: ". "),
                                        TextSpan(
                                          text: AppLocalizations.of(context)
                                                  ?.tryAgain ??
                                              "Try again",
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () =>
                                                model.init(model.experience),
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
              AppLocalizations.of(context)?.addToMyTrailsText ??
                  "Add to my trails",
              maxLines: 1,
              minFontSize: 18,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700, color: tealish),
            ),
          ),
        ),
        /*Small Title flex 25*/ Flexible(
          flex: 25,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)?.selectTrailText ?? "Select trail",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xff646464)),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
                    ),
                    child: Container(
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              flex: 60,
                              child: Container(
                                alignment: Alignment.center,
                                height: double.infinity,
                                width: double.infinity,
                                child: Text(
                                  AppLocalizations.of(context)?.newTrailText ??
                                      "New trail",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
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
                                              border: Border.fromBorderSide(
                                                  BorderSide.none)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                if (ExperienceDetailsHelper.getExperienceFeatures(
                        model.experience)
                    .isNotEmpty)
                  _SectionCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: ExperienceFacilitiesListView(model.experience),
                    ),
                  ),
                if (ExperienceDetailsHelper.getExperienceFeatures(
                        model.experience)
                    .isNotEmpty)
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
                            capitalizeFirstLetter(
                                AppLocalizations.of(context)?.description ??
                                    "Description"),
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
                if (model.experience.description.isNotEmpty)
                  const SizedBox(height: 20),

                // Contact Section
                if (model.experience.phone.isNotEmpty ||
                    model.experience.email.isNotEmpty ||
                    model.experience.website.isNotEmpty ||
                    model.experience.whatsApp.isNotEmpty ||
                    model.experience.facebook.isNotEmpty ||
                    model.experience.instagram.isNotEmpty)
                  _SectionCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contact", // Falling back to Contact if not in localizations
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1D1F),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ContactInfo(model.experience),
                        ],
                      ),
                    ),
                  ),

                if (model.experience.phone.isNotEmpty ||
                    model.experience.email.isNotEmpty ||
                    model.experience.website.isNotEmpty ||
                    model.experience.whatsApp.isNotEmpty ||
                    model.experience.facebook.isNotEmpty ||
                    model.experience.instagram.isNotEmpty)
                  const SizedBox(height: 20),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: tealish,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 18, color: Colors.white),
                        UIHelper.horizontalSpace(8),
                        Text(
                          'Show Schedule',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            TimetablesModal(model.experience.visitTime),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                experienceHorizontalList(
                  context: context,
                  experiences: model.experience.related,
                  experienceNameFontSize: 15,
                  experienceDestinationFontSize: 13,
                  experienceWidthRatio: 0.42,
                  onLongPress: (_context, _experience) => doNothing(),
                  onTap: (_context, _experience) {
                    Navigator.pushNamed(_context, '/experienceInfo',
                        arguments: _experience);
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
                    Navigator.pushNamed(_context, '/experienceInfo',
                        arguments: _experience);
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
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
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
                              baseWidgetModel.showOverlayWidget(
                                  false, Container());
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
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white),
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

  const ExperienceFacilitiesListView(this.experience, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return Consumer<ExperienceInfoModel>(
      builder: (context, model, _) {
        List<ExperienceFeature> features =
            ExperienceDetailsHelper.getExperienceFeatures(experience);
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

class ContactInfo extends StatelessWidget {
  final Experience experience;

  const ContactInfo(this.experience, {Key? key}) : super(key: key);

  String _truncate(String value) {
    // Show the whole email and phone number as requested
    return value;
  }

  Widget _buildRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              _truncate(text),
              style: TextStyle(fontSize: 12, color: Color(0xFF1D1D1F)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    if (experience.phone.isNotEmpty)
      rows.add(_buildRow(Icons.phone, experience.phone));
    if (experience.email.isNotEmpty)
      rows.add(_buildRow(Icons.email, experience.email));
    if (experience.website.isNotEmpty)
      rows.add(_buildRow(Icons.language, experience.website));
    if (experience.whatsApp.isNotEmpty)
      rows.add(_buildRow(Icons.message, experience.whatsApp));
    if (experience.facebook.isNotEmpty)
      rows.add(_buildRow(Icons.facebook, experience.facebook));
    if (experience.instagram.isNotEmpty)
      rows.add(_buildRow(Icons.camera_alt, experience.instagram));

    if (rows.isEmpty) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          top: 8,
          bottom: 8), // Removed side padding so it aligns with "Contact"
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }
}

class TimetablesModal extends StatelessWidget {
  final String visitTimeRaw;

  const TimetablesModal(this.visitTimeRaw, {Key? key}) : super(key: key);

  Map<String, String> _parseVisitTime(String raw) {
    if (raw.trim().isEmpty) return {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded
            .map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      }
    } catch (_) {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _parseVisitTime(visitTimeRaw);
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opening hours',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Column(
                children: days.map((day) {
                  final hours =
                      schedule[day.toLowerCase()] ?? schedule[day] ?? '';
                  final display = hours.isNotEmpty ? hours : 'Closed';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(day,
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(display,
                            style: TextStyle(color: Color(0xFF6E6E73))),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F7),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 16),
                      SizedBox(width: 8),
                      Text('Close'),
                    ],
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

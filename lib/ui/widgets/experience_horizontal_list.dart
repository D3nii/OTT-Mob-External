import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/anonymous.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:onetwotrail/ui/widgets/inside_show_modal_bottom_sheet.dart';
import 'package:onetwotrail/utils/experience_sub_menu_helper.dart';
import 'package:provider/provider.dart';

Column experienceHorizontalList({
  required BuildContext context,
  required List<Experience> experiences,
  required double experienceNameFontSize,
  required double experienceDestinationFontSize,
  required double experienceWidthRatio,
  Function(BuildContext context, Experience experience) onLongPress = _onLongPressDefault,
  required Function(BuildContext context, Experience experience) onTap,
  required double paddingLeft,
  required double paddingRight,
  bool showAddToTrailButton = true,
  bool showMoreOptionsButton = true,
  required double spaceBetweenExperiences,
  required String title,
  required double titleFontSize,
  Color? itemBackgroundColor,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: EdgeInsets.only(
          left: paddingLeft,
          right: paddingRight,
        ),
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: titleFontSize,
            color: const Color(0xFF1D1D1F),
            letterSpacing: -0.4,
          ),
        ),
      ),
      UIHelper.verticalSpace(12),
      Container(
        width: double.infinity,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: experiencesRow(
              context: context,
              experiences: experiences,
              experienceNameFontSize: experienceNameFontSize,
              experienceDestinationFontSize: experienceDestinationFontSize,
              experienceWidthRatio: experienceWidthRatio,
              onLongPress: onLongPress,
              onTap: onTap,
              paddingLeft: paddingLeft,
              paddingRight: paddingRight,
              showAddToTrailButton: showAddToTrailButton,
              showMoreOptionsButton: showMoreOptionsButton,
              spaceBetweenExperiences: spaceBetweenExperiences,
              itemBackgroundColor: itemBackgroundColor,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget experiencesRow({
  required BuildContext context,
  required List<Experience> experiences,
  required double experienceNameFontSize,
  required double experienceDestinationFontSize,
  required double experienceWidthRatio,
  Function(BuildContext context, Experience experience) onLongPress = _onLongPressDefault,
  required Function(BuildContext context, Experience experience) onTap,
  required double paddingLeft,
  required double paddingRight,
  bool showAddToTrailButton = true,
  bool showMoreOptionsButton = true,
  required double spaceBetweenExperiences,
  Color? itemBackgroundColor,
}) {
  var horizontalSpace = () => SizedBox(
        width: spaceBetweenExperiences,
      );
  double itemWidth = MediaQuery.of(context).size.width * experienceWidthRatio;
  List<Widget> children = [];
  for (Experience experience in experiences) {
    children.add(experienceItem(
      context: context,
      height: itemWidth,
      width: itemWidth,
      experience: experience,
      experienceDestinationFontSize: experienceDestinationFontSize,
      experienceNameFontSize: experienceNameFontSize,
      onLongPress: () {
        return onLongPress(context, experience);
      },
      onTap: () {
        onTap(context, experience);
            },
      showAddToTrailButton: showAddToTrailButton,
      showMoreOptionsButton: showMoreOptionsButton,
      backgroundColor: itemBackgroundColor,
    ));
    children.add(horizontalSpace());
  }
  return Padding(
    padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

_onLongPressDefault(BuildContext context, Experience experience) {
  runBasedOnUser(context, onRegistered: () => moreOptionsExperienceCallback(context, experience: experience, baseModelShowDialog: () {}));
}

Widget experienceItem({
  required BuildContext context,
  required Experience experience,
  double experienceNameFontSize = 14,
  double experienceDestinationFontSize = 12,
  required double height,
  required double width,
  bool showAddToTrailButton = true,
  bool showMoreOptionsButton = true,
  required Function() onLongPress,
  required Function() onTap,
  Color? backgroundColor,
}) {
  return OpenContainer<bool>(
    transitionDuration: Duration(milliseconds: 500),
    transitionType: ContainerTransitionType.fade,
    tappable: false,
    closedElevation: 0,
    closedColor: backgroundColor ?? Colors.white,
    openBuilder: (context, closedContainer) {
      return MultiProvider(
        providers: [
          Provider.value(value: experience),
        ],
        child: ExperienceInfo(),
      );
    },
    closedBuilder: (context, openContainer) {
      var moreOptionsWidgets = [];
      if (showMoreOptionsButton) {
        moreOptionsWidgets.addAll([
          Row(
            children: <Widget>[
              Spacer(),
              Container(
                height: 27,
                width: 28,
                child: GestureDetector(
                  onTap: () async => await runBasedOnUser(
                    context,
                    onRegistered: () => moreOptionsExperienceCallback(context, experience: experience, baseModelShowDialog: () {}),
                  ),
                  child: ImageIcon(
                    AssetImage("assets/icons/elipsis.png"),
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ]);
      }
      var addToTrailWidgets = [];
      if (showAddToTrailButton) {
        addToTrailWidgets.addAll([
          Row(
            children: <Widget>[
              Spacer(),
              Container(
                height: 27,
                width: 27,
                child: GestureDetector(
                  onTap: () async => await runBasedOnUser(
                    context,
                    onRegistered: () => addToTrailCall(context, experience),
                  ),
                  child: CircleAvatar(
                    backgroundColor: viridian,
                    child: ImageIcon(
                      AssetImage("assets/icons/icon_plus.png"),
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]);
      }
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: greyColor,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      experience.imageUrls.first,
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                        child: Column(
                          children: <Widget>[
                            ...moreOptionsWidgets,
                            Spacer(),
                            ...addToTrailWidgets,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(4),
              Text(
                experience.name,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: experienceNameFontSize,
                  color: const Color(0xFF1D1D1F),
                ),
              ),
              Text(
                experience.destinationName,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: experienceDestinationFontSize,
                  color: const Color(0xFF6E6E73),
                ),
              ),
            ],
          ),
        ),
        onLongPress: () {
          onLongPress();
        },
        onTap: () {
          onTap();
          openContainer();
        },
      );
    },
  );
}

addToTrailCall(BuildContext context, Experience experience) async {
  final user = Provider.of<User>(context, listen: false);
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
        key: ValueKey(experience.experienceId),
        value: experience,
        child: InsideShowModalBottomSheet(
          user,
          experience,
          () {},
          addButton: () {},
        )),
  );
}

moreOptionsExperienceCallback(BuildContext context, {required Experience experience, required VoidCallback baseModelShowDialog}) async {
  final homeModel = Provider.of<HomeModel>(context, listen: false);
  ExperienceSubMenuHelper().deployShowDialog(
    experience,
    context,
    addToTrail: () async {
      homeModel.dialogsStreamController.add(Container());
      await addToTrailCall(context, experience);
    },
    close: () {
      Navigator.pop(context);
      homeModel.tabBarVisible = true;
    },
  );
}

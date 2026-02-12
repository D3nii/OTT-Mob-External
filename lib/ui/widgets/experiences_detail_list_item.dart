import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:onetwotrail/ui/widgets/dots_item_experience.dart';
import 'package:onetwotrail/utils/loaded_image_listener.dart';
import 'package:provider/provider.dart';

class ExperiencesListItem extends StatelessWidget {
  const ExperiencesListItem(
    this.showPlusIcon,
    this.showElipisisIcon, {
    Key? key,
    this.height = 200,
    this.containerWidth = double.infinity,
    this.plusAction,
    this.minusAction,
    this.ellipsisAction,
  }) : super(key: key);

  final bool showPlusIcon;
  final bool showElipisisIcon;
  final double height;
  final double containerWidth;
  final VoidCallback? plusAction;
  final VoidCallback? minusAction;
  final VoidCallback? ellipsisAction;

  @override
  Widget build(BuildContext context) {
    final experience = Provider.of<Experience>(context);
    final size = MediaQuery.of(context).size;
    try {
      return ChangeNotifierProvider<LoadedImageHandler>(
        create: (_) => LoadedImageHandler(),
        child: Consumer<LoadedImageHandler>(
          builder: (_, handler, __) => LocalExperienceListItem(
            containerWidth,
            height: height,
            onTapElipsisIcon: ellipsisAction != null ? ellipsisAction! : () {},
            onTapMinusIcon: minusAction != null ? minusAction! : () {},
            onTapPlusIcon: plusAction != null ? plusAction! : () {},
            experience: experience,
            title: experience.name,
            subtitle: Text(
              experience.destinationName,
              overflow: TextOverflow.ellipsis,
            ),
            image: experience.imageUrls.length > 0
                ? (Image.network(
                    experience.imageUrls.first,
                    fit: BoxFit.cover,
                    height: size.height * 0.26,
                    width: double.infinity,
                  )..image
                    .resolve(ImageConfiguration.empty)
                    .addListener(ImageStreamListener((_, __) => handler.loadFinish(0))))
                : Image.asset(
                    'assets/background_images/grey_background.jpg',
                    fit: BoxFit.scaleDown,
                    height: size.height * 0.26,
                    width: double.infinity,
                  ),
            showPlusIcon: showPlusIcon,
            showElipsisIcon: showElipisisIcon,
          ),
        ),
      );
    } catch (e) {
      return LocalExperienceListItem(
        containerWidth,
        height: height,
        onTapElipsisIcon: ellipsisAction != null ? ellipsisAction! : () {},
        onTapMinusIcon: minusAction != null ? minusAction! : () {},
        onTapPlusIcon: plusAction != null ? plusAction! : () {},
        experience: experience,
        title: experience.name,
        subtitle: Text(
          experience.destinationName,
          overflow: TextOverflow.ellipsis,
        ),
        image: Image.asset(
          'assets/background_images/grey_background.jpg',
          fit: BoxFit.scaleDown,
          height: size.height * 0.26,
          width: containerWidth,
        ),
        showPlusIcon: showPlusIcon,
        showElipsisIcon: showElipisisIcon,
      );
    }
  }
}

bool checkLength(List<String> images) {
  if (images.length > 0) {
    if (images[0] != '') {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

class LocalExperienceListItem extends StatelessWidget {
  const LocalExperienceListItem(
    this.containerWidth, {
    Key? key,
    required this.title,
    this.height,
    required this.subtitle,
    required this.onTapPlusIcon,
    required this.onTapMinusIcon,
    required this.onTapElipsisIcon,
    required this.image,
    required this.showPlusIcon,
    required this.showElipsisIcon,
    required this.experience,
  }) : super(key: key);

  final double containerWidth;
  final String title;
  final double? height;
  final Widget subtitle;
  final VoidCallback onTapPlusIcon;
  final VoidCallback onTapMinusIcon;
  final VoidCallback onTapElipsisIcon;
  final Widget image;
  final bool showPlusIcon;
  final bool showElipsisIcon;
  final Experience experience;

  @override
  Widget build(BuildContext context) {
  return Consumer<LoadedImageHandler>(
    builder: (_, handler, __) => OpenContainer(
      transitionDuration: Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fade,
      tappable: true,
      closedElevation: 0,
      closedColor: Color(0xfff9f9f9),
      openColor: Color(0xfff9f9f9),
      closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          side: BorderSide(color: Colors.blue, style: BorderStyle.none)),
      openBuilder: (context, _) => Provider.value(
        value: experience,
        child: ExperienceInfo(),
      ),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: () {
          openContainer();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            /*Container de la imagen*/ Flexible(
              // flex: 75,
              child: Container(
                //height: MediaQuery.of(context).size.height * 0.16, //height,
                child: ClipRRect(
                  borderRadius:
                      new BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  child: Container(
                      color: Colors.grey,
                      child: Stack(
                        children: <Widget>[
                          image,
                          showPlusIcon
                              ? Positioned(
                                  right: 17,
                                  bottom: 11,
                                  child: GestureDetector(
                                    child: Container(
                                      height: 27,
                                      width: 27,
                                      child: Stack(
                                        children: <Widget>[
                                          Align(
                                            child: Container(
                                              alignment: Alignment.bottomRight,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(18)),
                                                  border: Border.fromBorderSide(BorderSide.none)),
                                              height: 18,
                                              width: 18,
                                            ),
                                          ),
                                          Icon(
                                            Icons.add_circle,
                                            color: viridian,
                                            size: 27,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () => onTapPlusIcon(),
                                  ),
                                )
                              : Positioned(
                                  right: 17,
                                  bottom: 11,
                                  child: GestureDetector(
                                    child: Container(
                                      height: 22,
                                      width: 22,
                                      child: Stack(
                                        children: <Widget>[
                                          Align(
                                            child: Container(
                                              alignment: Alignment.bottomRight,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(18)),
                                                  border: Border.fromBorderSide(BorderSide.none)),
                                              height: 18,
                                              width: 18,
                                            ),
                                          ),
                                          Icon(
                                            Icons.remove_circle,
                                            color: tomato,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () => onTapMinusIcon(),
                                  ),
                                ),
                          StreamBuilder<bool>(
                              initialData: false,
                              stream: handler.loaded,
                              builder: (context, snapshot) {
                                return snapshot.data == true
                                    ? Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.black.withAlpha(204), Colors.transparent])),
                                      )
                                    : Container();
                              }),
                          showElipsisIcon
                              ? Positioned(
                                  top: 0,
                                  right: 4,
                                  child: GestureDetector(
                                      onTap: () {
                                        onTapElipsisIcon();
                                      },
                                      child: Container(
                                        height: 48,
                                        width: 48,
                                        color: Colors.transparent,
                                        child: Container(
                                          height: 24,
                                          width: 24,
                                          child: DotsItemExperience(),
                                        ),
                                      )),
                                )
                              : Container(),
                        ],
                      )),
                ),
              ),
            ),
            UIHelper.verticalSpace(5),
            SizedBox(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0, color: Colors.black),
                      ),
                      Container(alignment: Alignment.bottomCenter, child: subtitle)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

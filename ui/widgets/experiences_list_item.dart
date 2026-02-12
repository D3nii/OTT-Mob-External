import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dots_item_experience.dart';
import 'package:onetwotrail/utils/loaded_image_listener.dart';
import 'package:provider/provider.dart';

class ExperiencesListItem extends StatelessWidget {
  const ExperiencesListItem({
    Key? key,
    required this.moreMenu,
    required this.showPlusIcon,
    required this.showElipisisIcon,
    required this.showMinusIcon,
    this.height = 150,
    this.containerWidth = double.infinity,
    this.plusMenu,
    this.minusMenu,
    this.openContainer,
  }) : super(key: key);
  final Function(Experience) moreMenu;
  final bool showPlusIcon;
  final bool showElipisisIcon;
  final bool showMinusIcon;
  final double height;
  final double containerWidth;
  final Function(Experience)? plusMenu;
  final Function(Experience)? minusMenu;
  final VoidCallback? openContainer;

  @override
  Widget build(BuildContext context) {
    final experience = Provider.of<Experience>(context);
    final size = MediaQuery.of(context).size;
    try {
      return ChangeNotifierProvider<LoadedImageHandler>(
          create: (_) => LoadedImageHandler(),
          child: Consumer<LoadedImageHandler>(
              builder: (_, handler, __) => LocalExperienceListItem(
                    experience,
                    double.infinity,
                    openContainer,
                    moreMenuTap: () => moreMenu(experience),
                    minusMenu: () => minusMenu != null ? minusMenu!(experience) : () {},
                    plusMenu: () => plusMenu != null ? plusMenu!(experience) : () {},
                    height: height,
                    title: experience.name,
                    subtitle: Text(
                      experience.destinationName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    image: experience.imageUrls.isNotEmpty
                        ? (Image.network(
                            experience.imageUrls.first,
                            fit: BoxFit.cover,
                            height: size.width * 0.47,
                            width: double.infinity,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Container(
                                height: size.width * 0.47,
                                width: double.infinity,
                                color: grey125Color,
                              );
                            },
                          )..image
                            .resolve(ImageConfiguration.empty)
                            .addListener(ImageStreamListener((_, __) => handler.loadFinish(0))))
                        : Container(
                            height: size.width * 0.47,
                            width: double.infinity,
                          ),
                    showPlusIcon: showPlusIcon,
                    showElipsisIcon: showElipisisIcon,
                  )));
    } on NetworkImageLoadException {
      return Container(
        height: size.width * 0.47,
        width: double.infinity,
        color: grey125Color,
      );
    } catch (e) {
      return LocalExperienceListItem(
        experience,
        containerWidth,
        openContainer,
        moreMenuTap: () => moreMenu(experience),
        plusMenu: () => plusMenu != null ? plusMenu!(experience) : () {},
        minusMenu: () => minusMenu != null ? minusMenu!(experience) : () {},
        height: height,
        title: experience.name,
        subtitle: Text(
          experience.destinationName,
          overflow: TextOverflow.ellipsis,
        ),
        image: Image.asset(
          'assets/my_trails/no_image_available.png',
          fit: BoxFit.scaleDown,
          height: height,
          width: containerWidth,
        ),
        showPlusIcon: showPlusIcon,
        showElipsisIcon: showElipisisIcon,
      );
    }
  }
}

class LocalExperienceListItem extends StatelessWidget {
  const LocalExperienceListItem(
    this.experience,
    this.containerWidth,
    this.openContainer, {
    Key? key,
    required this.title,
    this.height,
    required this.subtitle,
    required this.moreMenuTap,
    required this.plusMenu,
    required this.minusMenu,
    required this.image,
    required this.showPlusIcon,
    required this.showElipsisIcon,
  }) : super(key: key);

  final Experience experience;
  final double containerWidth;
  final VoidCallback? openContainer;
  final String title;
  final double? height;
  final Widget subtitle;
  final VoidCallback moreMenuTap;
  final VoidCallback plusMenu;
  final VoidCallback minusMenu;
  final Widget image;
  final bool showPlusIcon;
  final bool showElipsisIcon;

  @override
  Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Consumer<LoadedImageHandler>(
        builder: (_, handler, __) => Container(
          child: ClipRRect(
            borderRadius: new BorderRadius.all(Radius.circular(15.0)),
            child: Container(
                color: Colors.grey,
                child: Stack(
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          if (openContainer != null) {
                            openContainer!();
                          }
                        },
                        child: image),
                    showElipsisIcon
                        ? StreamBuilder<bool>(
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
                            })
                        : Container(),
                    showElipsisIcon
                        ? Positioned(
                            top: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => moreMenuTap(),
                              child: Container(
                                height: 48,
                                width: 48,
                                color: Colors.transparent,
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  child: DotsItemExperience(),
                                ),
                              ),
                            ),
                          )
                        : Container(),
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
                                      color: Color.fromRGBO(27, 143, 69, 1),
                                      size: 27,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () => plusMenu(),
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
                                        height: 18, width: 18,
//
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
                              onTap: () => minusMenu(),
                            ),
                          )
                  ],
                )),
          ),
        ),
      ),
      UIHelper.verticalSpace(5),
      Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.0, color: Colors.black),
            ),
          ],
        ),
      ),
    ],
  );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:provider/provider.dart';

class BoardTrailExperienceItem extends StatelessWidget {
  const BoardTrailExperienceItem(
    this.experieceActionClicked,
    this.showPlusIcon, {
    Key? key,
    this.height = 163,
    this.containerWidth = double.infinity,
  }) : super(key: key);

  final Function(Experience) experieceActionClicked;
  final bool showPlusIcon;
  final double height;
  final double containerWidth;

  @override
  Widget build(BuildContext context) {
    final experience = Provider.of<Experience>(context);

    return OpenContainer(
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
      closedBuilder: (context, openContainer) => LocalBoardExperienceListItem(
        containerWidth,
        onTap: () {
          experieceActionClicked(experience);
        },
        title: experience.name,
        subtitle: Text(experience.destinationName),
        image: experience.imageUrls.length > 0
            ? Image.network(
                experience.imageUrls[0],
                fit: BoxFit.cover,
                height: height,
                width: containerWidth,
              )
            : Image.asset('assets/my_trails/no_image_available.png'),
        showPlusIcon: showPlusIcon,
      ),
    );
  }
}

class LocalBoardExperienceListItem extends StatelessWidget {
  const LocalBoardExperienceListItem(
    this.containerWidth, {
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.image,
    required this.showPlusIcon,
  }) : super(key: key);

  final double containerWidth;
  final String title;
  final Widget subtitle;
  final VoidCallback onTap;
  final Widget image;
  final bool showPlusIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: containerWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            child: ClipRRect(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              child: Container(
                  color: Colors.grey,
                  child: Stack(
                    children: <Widget>[
                      image,
                      showPlusIcon
                          ? Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 44,
                                width: 44,
                                child: GestureDetector(
                                  child: Container(
                                    height: 22,
                                    width: 22,
                                    child: Stack(
                                      children: <Widget>[
                                        Align(
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(18)),
                                                border: Border.fromBorderSide(BorderSide.none)),
                                            height: 18, width: 18,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.add_circle,
                                            color: tealish,
                                            size: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    onTap();
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  )),
            ),
          ),
        ),
        Container(
          width: containerWidth,
          child: Text(
            title,
            maxLines: 2,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

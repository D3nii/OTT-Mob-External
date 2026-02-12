import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:provider/provider.dart';

class FixedExperienceItem extends StatelessWidget {
  const FixedExperienceItem(
    this.experienceActionClicked, {
    Key? key,
    this.height = 163,
    this.containerWidth = double.infinity,
  }) : super(key: key);

  final Function(Experience) experienceActionClicked;
  final double height;
  final double containerWidth;

  @override
  Widget build(BuildContext context) {
    final experience = Provider.of<Experience>(context);
    return LocalExperienceListItem(
      containerWidth,
      onTap: () {
        experienceActionClicked(experience);
      },
      title: experience.name,
      image: Image.network(
        experience.imageUrls.isNotEmpty ? experience.imageUrls.first : '',
        fit: BoxFit.cover,
        height: height,
        width: containerWidth,
      ),
    );
  }
}

class LocalExperienceListItem extends StatelessWidget {
  const LocalExperienceListItem(
    this.containerWidth, {
    Key? key,
    required this.title,
    required this.onTap,
    required this.image,
  }) : super(key: key);

  final double containerWidth;
  final String title;
  final VoidCallback onTap;
  final Widget image;

  @override
  Widget build(BuildContext context) {
  return Container(
    width: containerWidth,
    decoration: BoxDecoration(
      color: Colors.grey.shade400,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          flex: 75,
          child: Container(
            child: ClipRRect(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              child: Container(
                  color: Colors.grey,
                  child: Stack(
                    children: <Widget>[
                      image,
                      Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                        ),
                      ),
                      Positioned(
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
                                  Icons.add_circle,
                                  color: tealish,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            onTap();
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ],
    ),
  );
  }
}

import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/viewModels/experiences_sub_menu_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/experience_actions.dart';
import 'package:provider/provider.dart';

class MainExperienceSubMenuView extends StatelessWidget {
  final VoidCallback close;
  final VoidCallback addToTrail;

  const MainExperienceSubMenuView({Key? key, required this.close, required this.addToTrail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<Experience, ExperiencesSubMenuModel>(
      create: (_) => ExperiencesSubMenuModel(),
      update: (_, experiences, model) {
        if (model == null) {
          return ExperiencesSubMenuModel()
            ..experiences = experiences
            ..init();
        }
        return model
          ..experiences = experiences
          ..init();
      },
      child: Consumer<ExperiencesSubMenuModel>(
        builder: (context, model, _) {
          var padding = UIHelper.defaultHorizontalPadding(context);
          Size mediaQuery = MediaQuery.of(context).size;
          return GestureDetector(
            onTap: () => close(),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              children: <Widget>[
                UIHelper.verticalSpace(91),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: (mediaQuery.width * 0.28) - padding),
                  child: ImageAndPlace(model.experiences),
                ),
                UIHelper.verticalSpace(19),
                Container(
                  padding: EdgeInsets.only(left: (mediaQuery.width * 0.30) - padding),
                  child: ExperienceActions(
                    model.experiences,
                    addToTrail: addToTrail,
                  ),
                ),
                UIHelper.verticalSpace(19),
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomRight,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: tomato),
                          ),
                          height: 40,
                          width: 40,
                        ),
                        Container(
                          height: 18,
                          width: 18,
                          child: Image.asset(
                            'assets/icons/close.png',
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () => close(),
                ),
                UIHelper.verticalSpace(86)
              ],
            ),
          );
        },
      ),
    );
  }
}

class ImageAndPlace extends StatelessWidget {
  final Experience experience;

  const ImageAndPlace(this.experience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.60,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: experience.imageUrls.isNotEmpty
                    ? NetworkImage(experience.imageUrls.first)
                    : AssetImage('assets/my_trails/no_image_available.png') as ImageProvider,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ]),
        Container(
          child: Column(
            children: <Widget>[
              UIHelper.verticalSpace(10),
              Container(
                alignment: Alignment.center,
                child: Text(
                  experience.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  experience.destinationName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

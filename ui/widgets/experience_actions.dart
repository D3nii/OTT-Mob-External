import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/viewModels/experience_actions_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:provider/provider.dart';

class ExperienceActions extends StatelessWidget {
  const ExperienceActions(
    this.experiences, {
    Key? key,
    required this.addToTrail,
  }) : super(key: key);

  final Experience experiences;
  final VoidCallback addToTrail;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<ApplicationApi, ExperienceActionsModel>(
      create: (_) => ExperienceActionsModel(),
      update: (_, applicationApi, model) {
        if (model != null) {
          model.experience = experiences;
          model.applicationApi = applicationApi;
          model.init();
        }
        return model ?? ExperienceActionsModel();
      },
      child: Consumer<ExperienceActionsModel>(
        builder: (context, model, _) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    addToTrail();
                  },
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          height: 40,
                          width: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(color: tealish, shape: BoxShape.circle),
                                height: 40,
                                width: 40,
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                child: Image.asset(
                                  'assets/icons/add.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      UIHelper.horizontalSpace(20),
                      Text(
                        AppLocalizations.of(context)?.addToTrailText ?? 'Add to Trail',
                        style: actionStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/experienceInfo', arguments: model.experience);
                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(color: tealish, shape: BoxShape.circle),
                              height: 40,
                              width: 40,
                            ),
                            Container(
                              height: 20,
                              width: 20,
                              child: Image.asset(
                                'assets/icons/singleIconList.png',
                                color: Colors.white,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.horizontalSpace(20),
                      Text(
                        AppLocalizations.of(context)?.goToDetailText ?? 'Go to Detail',
                        style: actionStyle(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ShowButton extends StatelessWidget {
  const ShowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Flexible(
        flex: 1,
        child: Container(),
      ),
      Flexible(
        flex: 39,
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 5,
                child: Container(),
              ),
              ButtonTheme(
                height: 30.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 4.0, backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)?.newTrailText ?? 'New Trail',
                            style: TextStyle(color: Colors.white, fontSize: 14.0),
                          ),
                          UIHelper.horizontalSpace(5),
                          GestureDetector(
                            child: Container(
                              height: 25,
                              width: 25,
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(36)),
                                          border: Border.fromBorderSide(BorderSide.none)),
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.add_circle,
                                      color: tomato,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                        ]),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      Flexible(
        flex: 60,
        child: Container(),
      )
    ]);
  }
}

TextStyle actionStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

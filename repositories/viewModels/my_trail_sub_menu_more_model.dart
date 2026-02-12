import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';

class MyTrailSubMenuMoreModel extends BaseModel {
  late Trail _trail;
  late TrailService _trailService;
  late BaseWidgetModel _baseWidgetModel;
  late ProfileService _profileService;
  late Stream<BaseResponse<User>> _userProfile;

  Trail get trail => _trail;

  TrailService get trailService => _trailService;

  BaseWidgetModel get baseWidgetModel => _baseWidgetModel;

  set baseWidgetModel(BaseWidgetModel value) {
    _baseWidgetModel = value;
    notifyListeners();
  }

  set profileService(ProfileService value) {
    _profileService = value;
  }

  set trail(Trail value) {
    _trail = value;
    notifyListeners();
  }

  set trailService(TrailService value) {
    _trailService = value;
    notifyListeners();
  }

  Stream<BaseResponse<User>> get userProfile => _userProfile;

  init() async {
    _userProfile = _profileService.getProfileInfo();
    notifyListeners();
  }

  ///Abandon Current Trail
  void abandonTrail(Trail trail) {
    ///ToDo go to the api an wait for the response of abandon trail
  }

  ///Show the Dialog Component Abandon Trail
  void showDialogComponentAbandon(BuildContext context, Trail trail) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              insetPadding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                height: 337,
                width: 296,
                child: Padding(
                    padding: const EdgeInsets.only(top: 33, left: 35, right: 35, bottom: 42),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${AppLocalizations.of(context)?.abandonTrailText ?? 'Abandon trail'}?",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: tomato),
                          ),
                        ),
                        UIHelper.verticalSpace(16),
                        Container(
                          child: Text(
                            AppLocalizations.of(context)?.thisTrailWillBeReset ?? 'This trail will be reset',
                            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
                          ),
                        ),
                        UIHelper.verticalSpace(26),
                        Container(
                          height: 50,
                          width: 196,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35.0), side: BorderSide(color: Colors.red)),
                              backgroundColor: tomato,
                              padding: EdgeInsets.all(8.0),
                            ),
                            onPressed: () {
                              abandonTrail(trail);
                            },
                            onLongPress: () {
                              abandonTrail(trail);
                            },
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)?.abandonText ?? 'Abandon',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Image.asset(
                                      'assets/icons/00AtomsBtnArrow.png',
                                      color: Colors.white,
                                    ),
                                  )
                                ]),
                          ),
                        ),
                        UIHelper.verticalSpace(16),
                        InkWell(
                          child: Container(
                            child: Text(
                              AppLocalizations.of(context)?.cancelText ?? 'Cancel',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )),
              ));
        });
  }

  List<String> getTrailImagesFromExperiences() {
    List<String> images = [];
    for (Experience experience in trail.experiences) {
      images.add(experience.imageUrls.first);
    }
    return images;
  }
}

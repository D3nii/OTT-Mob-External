import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/views/main_experience_sub_menu_view.dart';
import 'package:provider/provider.dart';

class ExperienceSubMenuHelper extends BaseModel {
  ///Variables

  ///Getters

  ///Setters

  ///First Method to load data
  void init() {}

  Future<void> deployShowDialog(
    Experience experience,
    BuildContext context, {
    required VoidCallback addToTrail,
    required VoidCallback close,
  }) async {
    Widget experienceActionWidget = Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(0),
      child: Provider<Experience>.value(
        value: experience,
        key: ValueKey(experience.experienceId),
        child: MainExperienceSubMenuView(
          addToTrail: addToTrail,
          close: close,
        ),
      ),
    );

    await showModal<String>(
        context: context,
        builder: (context) => experienceActionWidget,
        configuration: FadeScaleTransitionConfiguration(
            barrierColor: black79Transparent,
            transitionDuration: Duration(milliseconds: 300),
            reverseTransitionDuration: Duration(milliseconds: 0)));
  }
}

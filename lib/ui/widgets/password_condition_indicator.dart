import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';

class PasswordConditionIndicator extends StatelessWidget {
  const PasswordConditionIndicator(this.isActive, {Key? key}) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      AssetImage(isActive ? "assets/icons/register_ok.png" : "assets/icons/register_cancel.png"),
      size: 16,
      color: tealish,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';

class TabBarButton extends StatelessWidget {
  const TabBarButton(
    this.title,
    this.activeIcon,
    this.inactiveIcon,
    this.active,
    this.onTap, {
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  final String title;
  final AssetImage activeIcon;
  final AssetImage inactiveIcon;
  final bool active;
  final Function onTap;
  final Function? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () async {
          onTap();
        },
        onLongPress: onLongPress != null ? () async {
          onLongPress!();
        } : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Column(
            children: <Widget>[
              ImageIcon(
                active ? activeIcon : inactiveIcon,
                size: 32,
                color: primaryColor,
              ),
              UIHelper.verticalSpace(3),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: primaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

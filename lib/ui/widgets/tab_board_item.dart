import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';

class TabBoardItem extends StatelessWidget {
  const TabBoardItem(
    this.show,
    this.onTap, {
    Key? key,
  }) : super(key: key);

  final bool show;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
      width: mediaQuery.width * 0.213,
      decoration: BoxDecoration(
          color: tealish,
          border: show
              ? Border(
                  bottom: BorderSide(color: tomato, width: 3),
                  left: BorderSide.none,
                  right: BorderSide.none,
                  top: BorderSide.none,
                )
              : Border(top: BorderSide.none, bottom: BorderSide.none, left: BorderSide.none, right: BorderSide.none)),
      child: TextButton(
        style: ButtonStyle(
          overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
        ),
        onPressed: onTap,
        child: Text(
          AppLocalizations.of(context)?.boardText ?? 'Board',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}

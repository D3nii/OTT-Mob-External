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
                  bottom: BorderSide(color: tomato, width: 3.5),
                  left: BorderSide.none,
                  right: BorderSide.none,
                  top: BorderSide.none,
                )
              : Border(top: BorderSide.none, bottom: BorderSide.none, left: BorderSide.none, right: BorderSide.none)),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(bottom: 8, top: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: Colors.transparent,
        ),
        onPressed: onTap,
        child: Text(
          AppLocalizations.of(context)?.boardText ?? 'Board',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}

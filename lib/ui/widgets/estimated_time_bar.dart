import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/v2/util/duration.dart';

class EstimatedTimeBar extends StatelessWidget {
  const EstimatedTimeBar(this.duration, this.isUpdating, {Key? key}) : super(key: key);

  final Duration duration;

  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tealish, width: 2))),
      width: double.infinity,
      height: mediaQuery.height * 0.064,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            flex: 45,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                AppLocalizations.of(context)?.estimatedTime ?? 'Estimated Time',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 15,
            child: Container(),
          ),
          Flexible(
            flex: 40,
            child: Center(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      'assets/icons/car.png',
                    ),
                    Container(
                      width: mediaQuery.width * 0.10,
                    ),
                    Text(
                      _getDurationText(context),
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getDurationText(BuildContext context) {
    // If is updating, return updating text
    if (isUpdating) {
      return AppLocalizations.of(context)?.updatingText ?? 'Updating...';
    }
    // Return the text of the duration
    return fromDurationToText(context, duration);
  }
}

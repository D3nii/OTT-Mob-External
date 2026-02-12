import 'package:flutter/widgets.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/v2/util/string.dart';

String fromDurationToText(BuildContext context, Duration duration) {
  // Load the localizations
  var localizations = AppLocalizations.of(context)!;
  // If duration is less than 1 day, return hours
  if (duration.inHours < Duration.hoursPerDay) {
    return fromCountToText(duration.inHours, localizations.hour, localizations.hours);
  }
  // Set days to the ceil of the division of the duration in hours by 24
  int days = (duration.inHours / Duration.hoursPerDay).ceil();
  return fromCountToText(days, localizations.day, localizations.days);
}

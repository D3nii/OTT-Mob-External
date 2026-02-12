import 'package:flutter/widgets.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:provider/provider.dart';

final _log = Logger('Anonymous');

Future<void> runBasedOnUser(BuildContext context, {Future<void> Function()? onUnregistered, Future<void> Function()? onRegistered}) async {
  _log.info('Checking user authentication status');
  var apiContext = Provider.of<ApplicationApi>(context, listen: false).context;

  if (apiContext.hasToken) {
    _log.info('Executing registered user flow');
    if (onRegistered != null) {
      return onRegistered();
    }
    _log.warning('No registered user handler provided');
    return;
  }

  _log.info('Executing unregistered user flow');
  if (onUnregistered != null) {
    return onUnregistered();
  }

  _log.info('Showing registration prompt dialog');
  var title = AppLocalizations.of(context)?.pleaseRegisterTitle ?? 'Please Register';
  var body = AppLocalizations.of(context)?.pleaseRegisterBody ?? 'You need to register to access this feature';
  return Dialogs.showErrorDialog(context: context, title: title, body: body);
}

Future<void> doNothing() async {}

bool isAdminUser(BuildContext context) {
  final apiContext = Provider.of<ApplicationApi>(context, listen: false).context;
  return apiContext.isAdmin;
}

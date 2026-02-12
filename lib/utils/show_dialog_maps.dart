import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/v2/navigation_app.dart';

class ShowDialogMaps {
  final Logger _logger = Logger('ShowDialogMaps');

  /// Shows a dialog with navigation app options for the given experience
  ///
  /// [context] The build context
  /// [experience] The experience containing coordinates
  /// [afterLaunch] Optional callback to execute after launching a navigation app
  /// [returnFuture] Whether to return the Future from showModal (used for showDialogMapsTrails)
  Future<void> _showNavigationDialog(BuildContext context, Experience experience, {Function? afterLaunch, bool returnFuture = false}) {
    final dialog = showModal(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(249, 249, 249, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(32),
            ),
          ),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: NavigationApps.asList().length + 1,
            itemBuilder: (BuildContext context, int index) {
              // Last item is the Cancel button
              if (index == NavigationApps.asList().length) {
                return _buildCancelButton(context);
              } else {
                // Navigation app option
                return _buildNavigationAppButton(
                  context,
                  index,
                  experience,
                  afterLaunch,
                );
              }
            },
          ),
        );
      },
    );

    return returnFuture ? dialog : Future.value();
  }

  /// Builds the cancel button for the dialog
  Widget _buildCancelButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: ListTile(
          title: Center(
            child: Text(
              AppLocalizations.of(context)?.cancelText ?? 'Cancel',
              textScaler: const TextScaler.linear(1.2),
              style: TextStyle(color: Colors.red),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// Builds a navigation app button for the dialog
  Widget _buildNavigationAppButton(BuildContext context, int index, Experience experience, Function? afterLaunch) {
    final navigationApp = NavigationApps.asList()[index];

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        title: Center(
          child: Text(
            '${AppLocalizations.of(context)?.openInText ?? 'Open in'} ${navigationApp.name}',
            textScaler: const TextScaler.linear(1.2),
            style: TextStyle(color: tealish),
          ),
        ),
        onTap: () async {
          _logger.info('Attempting to launch ${navigationApp.name} with coordinates: ${experience.latitude}, ${experience.longitude}');
          bool success = await navigationApp.launchLocation(
            experience.latitude,
            experience.longitude,
          );

          if (!success && context.mounted) {
            _logger.warning('Failed to launch ${navigationApp.name}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${navigationApp.name} could not be launched. Make sure it is installed.'),
                duration: Duration(seconds: 3),
              ),
            );
          }

          afterLaunch?.call();
        },
      ),
    );
  }

  /// Shows a dialog with navigation app options for trails
  /// Returns a Future that completes when the dialog is closed
  Future<void> showDialogMapsTrails(BuildContext context, Experience experience, Function afterLaunch) {
    return _showNavigationDialog(
      context,
      experience,
      afterLaunch: afterLaunch,
      returnFuture: true,
    );
  }

  /// Shows a dialog with navigation app options for experiences
  Future<void> showDialogMapsExperience(BuildContext context, Experience experience, {Function? afterLaunch}) {
    return _showNavigationDialog(
      context,
      experience,
      afterLaunch: afterLaunch,
    );
  }
}

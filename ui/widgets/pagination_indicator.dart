import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';

class PaginationIndicator extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasError;
  final VoidCallback? onRetry;
  final Color? buttonColor;

  const PaginationIndicator({
    Key? key,
    required this.isLoadingMore,
    required this.hasError,
    this.onRetry,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: RefreshProgressIndicator(),
        ),
      );
    }

    if (hasError) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.somethingWentWrongText,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? viridian,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)!.tryAgain,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(height: 16);
  }
}

// Removed flare_flutter import
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';

class DialogContentView extends StatelessWidget {
  const DialogContentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return SizedBox(
      height: mediaQuery.height,
      width: mediaQuery.width,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                height: mediaQuery.height,
                width: mediaQuery.width,
                child: Image.asset(
                  'assets/background_images/color_bg.png',
                  fit: BoxFit.cover,
                )),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: mediaQuery.height * 0.21,
                    width: mediaQuery.width * 0.40,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4.0,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(mediaQuery.height * 0.0119),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.12),
                    child: Text(
                      AppLocalizations.of(context)?.yourItineraryWillBeReady ?? "Your itinerary will be ready",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

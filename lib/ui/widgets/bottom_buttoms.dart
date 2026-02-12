import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/services/anonymous.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';

class BottomButtoms extends StatelessWidget {
  const BottomButtoms(this.experience, this.addTrail, {Key? key}) : super(key: key);

  final Experience experience;
  final VoidCallback addTrail;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // todo: restore after share reimplementation
        // Flexible(
        //   flex: 24,
        //   child: Row(children: <Widget>[
        //     Container(
        //       child: RawMaterialButton(
        //         elevation: 0,
        //         fillColor: Colors.white,
        //         child: Image.asset(
        //           "assets/icons/send_icon.png",
        //           color: tealish,
        //           height: 25,
        //           width: 25,
        //         ),
        //         shape: CircleBorder(),
        //         onPressed: () {},
        //       ),
        //     ),
        //   ]),
        // ),
        Expanded(
          flex: 60,
          child: Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 32, left: 32, right: 32),
            child: Container(
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0, backgroundColor: tealish,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(right: 5),
                    child: AutoSizeText(
                      AppLocalizations.of(context)?.addToTrailText ?? 'Add to Trail',
                      maxLines: 1,
                      maxFontSize: 14,
                      minFontSize: 10,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        wordSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                await runBasedOnUser(context, onRegistered: () async => addTrail());
              },
            )),
          ),
        ),
      ],
    );
  }
}

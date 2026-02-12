import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
// import 'package:onetwotrail/repositories/services/profile_service.dart'; // Not needed
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/experience_mark_as_done_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:provider/provider.dart';

class ShowDialogExperienceMarkAsDone extends StatelessWidget {
  const ShowDialogExperienceMarkAsDone(this.experienceInTrailId, this.itineraryId, this.experience, {Key? key})
      : super(key: key);

  final int experienceInTrailId;
  final int itineraryId;
  final Experience experience;

  @override
  Widget build(BuildContext _context) {
    Size mediaQuery = MediaQuery.of(_context).size;
    return ChangeNotifierProvider<ExperienceMarkAsDoneModel>(
      create: (context) {
        // ProfileService not needed
        // var profileService = Provider.of<ProfileService>(context, listen: false);
        var trailService = Provider.of<TrailService>(context, listen: false);
        return ExperienceMarkAsDoneModel(trailService);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pop(_context, false);
        },
        child: Scaffold(
          backgroundColor: black70Transparent,
          body: Dialog(
            insetPadding: EdgeInsets.all(0),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              width: mediaQuery.width * 0.821,
              child: Padding(
                padding: const EdgeInsets.only(top: 36, left: 27, right: 36, bottom: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        AppLocalizations.of(_context)?.wouldYouRecommend ?? 'Would you recommend?',
                        minFontSize: 12,
                        maxFontSize: 32,
                        maxLines: 2,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: tomato),
                      ),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.0061),
                    Container(
                      child: AutoSizeText(
                        AppLocalizations.of(_context)?.yourVotesCouldMakeThis ?? 'Your votes could make this',
                        minFontSize: 10,
                        maxFontSize: 12,
                        maxLines: 2,
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
                      ),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.0044),
                    _ContainerOfLikesButtons(),
                    UIHelper.verticalSpace(mediaQuery.height * 0.0081),
                    _MarkAsDoneButton(experienceInTrailId, itineraryId),
                    UIHelper.verticalSpace(mediaQuery.height * 0.005),
                    Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: mediaQuery.height * 0.0361,
                        width: mediaQuery.width * 0.25,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.only(right: 0, left: 15),
                            backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(_context)?.reportText ?? 'Report',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  child: Image.asset(
                                    'assets/icons/alert.png',
                                    height: 35,
                                    width: 35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(_context, '/reportIssue', arguments: experience);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkAsDoneButton extends StatelessWidget {
  const _MarkAsDoneButton(this.experienceInTrailId, this.itineraryId, {Key? key}) : super(key: key);

  final int experienceInTrailId;
  final int itineraryId;

  @override
  Widget build(BuildContext _context) {
    return Consumer<ExperienceMarkAsDoneModel>(builder: (context, model, _) {
      return Container(
        height: 50,
        width: 196,
        child: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0), side: BorderSide(color: tealish)),
            backgroundColor: tealish,
            padding: EdgeInsets.all(8.0),
          ),
          onPressed: () async {
            bool success = await model.changeItineraryStatus(experienceInTrailId, itineraryId);
            if (success) {
              return Navigator.pop(context, true);
            } else {
              await Future.delayed(Duration(milliseconds: 200));
              Dialogs.showMessageDialog(
                context,
                AppLocalizations.of(context)?.somethingWentWrongRequestText ?? 'Something went wrong with the request',
                () {},
              );
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)?.markAsDone ?? 'Mark as done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ContainerOfLikesButtons extends StatelessWidget {
  const _ContainerOfLikesButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return Consumer<ExperienceMarkAsDoneModel>(builder: (context, model, _) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: TextButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                    (states) => new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(32.0),
                    ),
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => Colors.transparent,
                  )),
              child: Image.asset(
                model.like == 1 ? 'assets/icons/like_active.png' : 'assets/icons/like_inactive.png',
              ),
              onPressed: () async {
                model.like = model.like == 1 ? 0 : 1;
              },
            ),
          ),
          Container(
            child: TextButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
                    (states) => new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(32.0),
                    ),
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => Colors.transparent,
                  )),
              child: Image.asset(
                model.like == 2 ? 'assets/icons/dislike_active.png' : 'assets/icons/dislike_inactive.png',
              ),
              onPressed: () async {
                model.like = model.like == 2 ? 0 : 2;
              },
            ),
          ),
        ],
      );
    });
  }
}

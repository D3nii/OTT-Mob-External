import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/anonymous.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/trail_preview_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/added_to_trail.dart';
import 'package:onetwotrail/ui/widgets/experience_horizontal_list.dart';
import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_client.dart';
import 'package:onetwotrail/v2/event/event_name.dart';
import 'package:onetwotrail/v2/event/event_source_view.dart';
import 'package:onetwotrail/v2/event/event_tag.dart';
import 'package:provider/provider.dart';

import '../../widgets/circular_progress_bar.dart';
import '../../widgets/estimated_time_bar.dart';

class TrailPreviewView extends StatelessWidget {
  const TrailPreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreviewTrailModel>(
      create: (context) {
        var trail = Provider.of<Trail>(context, listen: false);
        var trailService = Provider.of<TrailService>(context, listen: false);
        var profileService = Provider.of<ProfileService>(context, listen: false);
        return PreviewTrailModel(trailService, profileService)..initState(trail);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            AppBarGenerateContainer(),
            Container(
                child: Consumer<PreviewTrailModel>(
                    builder: (context, model, _) => EstimatedTimeBar(model.duration, false))),
            const TrailPreviewViewBody(),
          ],
        ),
      ),
    );
  }
}

class AppBarGenerateContainer extends StatelessWidget {
  const AppBarGenerateContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<PreviewTrailModel>(
      builder: (context, model, _) {
        return Container(
          height: mediaQuery.height * 0.13,
          width: mediaQuery.width,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                height: mediaQuery.height * 0.13,
                width: mediaQuery.width,
                child: Image.asset(
                  'assets/main_filter/appbar_background_image.png',
                  fit: BoxFit.fill,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, top: MediaQuery.of(context).padding.top),
                  child: Row(
                    children: [
                      Container(
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          highlightColor: Colors.transparent,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            model.currentTrailPreview.name.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class TrailPreviewViewBody extends StatelessWidget {
  const TrailPreviewViewBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext parentContext) {
    return Consumer<PreviewTrailModel>(
      builder: (context, model, _) {
        final height = MediaQuery.of(context).size.height;
        final heightForOptionalView = height - height * 0.3;
        return StreamBuilder<BaseResponse<User>>(
            initialData: model.profileService.userResponse,
            stream: model.profileService.userResponseStream,
            builder: (context, snapshot) {
              return Expanded(
                child: Stack(
                  children: <Widget>[
                    model.state != ViewState.Busy && !model.showErrorStatus
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                margin: const EdgeInsets.all(0),
                                width: double.maxFinite,
                                child: GridView.builder(
                                  padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: model.currentTrailPreview.experiences.length,
                                  shrinkWrap: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14.0,
                                      mainAxisSpacing: 14.0,
                                      mainAxisExtent: 260),
                                  itemBuilder: (context, index) {
                                    // Get the max size from the context
                                    var width = MediaQuery.of(context).size.width / 2 - 14;
                                    var height = MediaQuery.of(context).size.width / 2 - 28;
                                    // Return the experience item
                                    var experience = model.currentTrailPreview.experiences[index];
                                    return experienceItem(
                                      context: context,
                                      experience: experience,
                                      height: height,
                                      width: width,
                                      onLongPress: doNothing,
                                      onTap: () {
                                        Provider.of<EventClient>(context, listen: false).createEvent(Event(
                                            EventName.experience_profile_viewed, EventSourceView.trail_experience, {
                                          EventTag.experience_id: experience.experienceId.toString(),
                                          EventTag.experience_name: experience.name,
                                          EventTag.trail_id: model.currentTrailPreview.id.toString(),
                                          EventTag.trail_name: model.currentTrailPreview.name,
                                        }));
                                      },
                                      showAddToTrailButton: true,
                                      showMoreOptionsButton: false,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  AppLocalizations.of(context)!.experiencesOnTheMap,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              UIHelper.verticalSpace(10),
                              Container(
                                height: 200,
                                color: Colors.black26,
                                child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                          model.currentTrailPreview.latitude, model.currentTrailPreview.longitude),
                                    ),
                                    onMapCreated: model.onTrailMapCreated,
                                    markers: model.getMarkers(trail: model.currentTrailPreview),
                                    gestureRecognizers: Set()
                                      ..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()))),
                              ),
                              Container(
                                height: 150,
                              ),
                            ],
                          )
                        : model.state == ViewState.Busy
                            ? Container(
                                height: heightForOptionalView,
                                child: Center(child: CircularProgressBar()),
                              )
                            : Container(
                                height: 200,
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.bottomLeft,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    text: AppLocalizations.of(context)!.somethingWentWrongRequestText,
                                    children: [
                                      TextSpan(text: ". "),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!.tryAgain,
                                        style: TextStyle(decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => model.showTrailDetails(model.currentTrailPreview, true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                    model.state != ViewState.Busy && !model.showErrorStatus
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(31, 28, 20, 40),
                              color: Colors.white,
                              child: Row(
                                children: <Widget>[
                                  // todo: restore after share reimplementation
                                  // IconButton(
                                  //   icon: ImageIcon(
                                  //     AssetImage("assets/icons/send_icon.png"),
                                  //     size: 42,
                                  //     color: primaryColor,
                                  //   ),
                                  //   color: primaryColor,
                                  //   onPressed: () {},
                                  // ),
                                  // Container(
                                  //   child: UIHelper.horizontalSpace(35),
                                  //   height: 50,
                                  // ),
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: model.addRequested
                                            ? Center(
                                                child: SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                              ))
                                            : Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                    Container(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(
                                                        AppLocalizations.of(context)!.addToMyTrailsText,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    UIHelper.horizontalSpace(12),
                                                  ]),
                                        onPressed: () async {
                                          return runBasedOnUser(context, onRegistered: () async {
                                            if (model.addRequested) {
                                              return;
                                            }
                                            bool success = await model.addCurrentTrailToCollection(context);
                                            if (!success && model.error) {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      AppLocalizations.of(context)!.somethingWentWrongRequestText));
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              model.error = !model.error;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    model.showTrailAdded
                        ? AddedToTrail(
                            model.isAdded
                                ? AppLocalizations.of(context)!.trailAddedText
                                : AppLocalizations.of(context)!.deleteText,
                          )
                        : Container()
                  ],
                ),
              );
            });
      },
    );
  }
}

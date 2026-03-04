// ui/views/trail_preview/trail_preview_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/config/config.dart';
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
import 'package:onetwotrail/ui/widgets/cupertino_back_button.dart';
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
        var profileService =
            Provider.of<ProfileService>(context, listen: false);
        var config = Provider.of<Config>(context, listen: false);
        return PreviewTrailModel(
            trailService, profileService, config.googleMapsApiKey)
          ..initState(trail);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Column(
          children: [
            AppBarGenerateContainer(),
            // Trail name and description section
            Consumer<PreviewTrailModel>(
              builder: (context, model, _) => Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.currentTrailPreview.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                        letterSpacing: -0.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((model.currentTrailPreview.description ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        model.currentTrailPreview.description ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6E6E73),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
                child: Consumer<PreviewTrailModel>(
                    builder: (context, model, _) =>
                        EstimatedTimeBar(model.duration, false))),
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
              Container(
                height: mediaQuery.height * 0.13,
                width: mediaQuery.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 10, top: MediaQuery.of(context).padding.top),
                  child: Row(
                    children: [
                      CupertinoBackButton(
                        label: AppLocalizations.of(context)?.backText ?? "Back",
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                      // Removed trail name label per design request
                      // Expanded(
                      //   child: Container(
                      //     child: Text(
                      //       model.currentTrailPreview.name.toUpperCase(),
                      //       overflow: TextOverflow.ellipsis,
                      //       maxLines: 2,
                      //       style: TextStyle(
                      //         fontFamily: "Poppins",
                      //         fontSize: 18,
                      //         fontWeight: FontWeight.w700,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // )
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

class TrailPreviewViewBody extends StatefulWidget {
  const TrailPreviewViewBody({Key? key}) : super(key: key);

  @override
  State<TrailPreviewViewBody> createState() => _TrailPreviewViewBodyState();
}

class _TrailPreviewViewBodyState extends State<TrailPreviewViewBody> {
  bool _showAllExperiences = false;

  @override
  Widget build(BuildContext parentContext) {
    return Consumer<PreviewTrailModel>(
      builder: (context, model, _) {
        final height = MediaQuery.of(context).size.height;
        final heightForOptionalView = height - height * 0.3;
        final experienceCount = _showAllExperiences
            ? model.currentTrailPreview.experiences.length
            : (model.currentTrailPreview.experiences.length > 6
                ? 6
                : model.currentTrailPreview.experiences.length);
        return StreamBuilder<BaseResponse<User>>(
            initialData: model.profileService.userResponse,
            stream: model.profileService.userResponseStream,
            builder: (context, snapshot) {
              return Expanded(
                child: Stack(
                  children: <Widget>[
                    model.state != ViewState.Busy && !model.showErrorStatus
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            children: <Widget>[
                              const SizedBox(height: 8),
                              const Text(
                                'Experiences',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D1D1F),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                width: double.maxFinite,
                                child: GridView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: experienceCount,
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12.0,
                                          mainAxisSpacing: 12.0,
                                          mainAxisExtent: 240),
                                  itemBuilder: (context, index) {
                                    // Get the max size from the context
                                    var width =
                                        MediaQuery.of(context).size.width / 2 -
                                            14;
                                    var height =
                                        MediaQuery.of(context).size.width / 2 -
                                            28;
                                    // Return the experience item
                                    var experience = model
                                        .currentTrailPreview.experiences[index];
                                    return experienceItem(
                                      context: context,
                                      experience: experience,
                                      height: height,
                                      width: width,
                                      experienceNameFontSize: 12,
                                      experienceDestinationFontSize: 10,
                                      onLongPress: doNothing,
                                      onTap: () {
                                        Provider.of<EventClient>(context,
                                                listen: false)
                                            .createEvent(Event(
                                                EventName
                                                    .experience_profile_viewed,
                                                EventSourceView
                                                    .trail_experience,
                                                {
                                              EventTag.experience_id: experience
                                                  .experienceId
                                                  .toString(),
                                              EventTag.experience_name:
                                                  experience.name,
                                              EventTag.trail_id: model
                                                  .currentTrailPreview.id
                                                  .toString(),
                                              EventTag.trail_name: model
                                                  .currentTrailPreview.name,
                                            }));
                                      },
                                      showAddToTrailButton: true,
                                      showMoreOptionsButton: false,
                                      backgroundColor: const Color(0xFFF5F5F7),
                                    );
                                  },
                                ),
                              ),
                              if (model.currentTrailPreview.experiences.length >
                                      6 &&
                                  !_showAllExperiences) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 16),
                                  child: Center(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: tealish,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showAllExperiences = true;
                                        });
                                      },
                                      child: const Text(
                                        'Show More',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (model.currentTrailPreview.experiences.length >
                                      6 &&
                                  _showAllExperiences) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 16),
                                  child: Center(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: tealish,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showAllExperiences = false;
                                        });
                                      },
                                      child: const Text(
                                        'Show Less',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Text(
                                AppLocalizations.of(context)!
                                    .experiencesOnTheMap,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D1D1F),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 200,
                                  color: Colors.black26,
                                  child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            model.currentTrailPreview.latitude,
                                            model
                                                .currentTrailPreview.longitude),
                                      ),
                                      onMapCreated: model.onTrailMapCreated,
                                      markers: model.getMarkers(
                                          trail: model.currentTrailPreview),
                                      polylines: model.polylines,
                                      gestureRecognizers: Set()
                                        ..add(Factory<
                                                OneSequenceGestureRecognizer>(
                                            () => EagerGestureRecognizer()))),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Related Experiences',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D1D1F),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 260,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: model.currentTrailPreview
                                              .experiences.length >
                                          5
                                      ? 5
                                      : model.currentTrailPreview.experiences
                                          .length,
                                  itemBuilder: (context, index) {
                                    var experience = model
                                        .currentTrailPreview.experiences[index];
                                    var width =
                                        MediaQuery.of(context).size.width / 2.5;
                                    var height = width;
                                    var itemCount = model.currentTrailPreview
                                                .experiences.length >
                                            5
                                        ? 5
                                        : model.currentTrailPreview.experiences
                                            .length;
                                    return Container(
                                      margin: EdgeInsets.only(
                                        right: index == itemCount - 1 ? 0 : 12,
                                      ),
                                      child: experienceItem(
                                        context: context,
                                        experience: experience,
                                        height: height,
                                        width: width,
                                        onLongPress: doNothing,
                                        onTap: () {
                                          Provider.of<EventClient>(context,
                                                  listen: false)
                                              .createEvent(Event(
                                                  EventName
                                                      .experience_profile_viewed,
                                                  EventSourceView
                                                      .trail_experience,
                                                  {
                                                EventTag.experience_id:
                                                    experience.experienceId
                                                        .toString(),
                                                EventTag.experience_name:
                                                    experience.name,
                                                EventTag.trail_id: model
                                                    .currentTrailPreview.id
                                                    .toString(),
                                                EventTag.trail_name: model
                                                    .currentTrailPreview.name,
                                              }));
                                        },
                                        showAddToTrailButton: false,
                                        showMoreOptionsButton: false,
                                        backgroundColor:
                                            const Color(0xFFF5F5F7),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                height: 50,
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
                                    text: AppLocalizations.of(context)!
                                        .somethingWentWrongRequestText,
                                    children: [
                                      TextSpan(text: ". "),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .tryAgain,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              model.showTrailDetails(
                                                  model.currentTrailPreview,
                                                  true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                    model.state != ViewState.Busy && !model.showErrorStatus
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 12, 24, 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: SafeArea(
                                top: false,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: tealish,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: model.addRequested
                                        ? const Center(
                                            child: SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!
                                                .addToMyTrailsText,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                    onPressed: () async {
                                      return runBasedOnUser(context,
                                          onRegistered: () async {
                                        if (model.addRequested) {
                                          return;
                                        }
                                        bool success = await model
                                            .addCurrentTrailToCollection(
                                                context);
                                        if (!success && model.error) {
                                          final snackBar = SnackBar(
                                            content: Text(AppLocalizations.of(
                                                    context)!
                                                .somethingWentWrongRequestText),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                          model.error = !model.error;
                                        }
                                      });
                                    },
                                  ),
                                ),
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

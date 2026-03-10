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
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/views/trail_preview/itinerary_widgets.dart';

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
  // Removed _buildItineraryList and state properties to use TrailItineraryModal instead

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
                            key: const PageStorageKey('overview_list'),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: tealish,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          TrailItineraryModal(model: model),
                                    );
                                  },
                                  child: const Text(
                                    'Show Itinerary',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
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
                              const SizedBox(height: 20),
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

class TrailItineraryModal extends StatefulWidget {
  final PreviewTrailModel model;

  const TrailItineraryModal({Key? key, required this.model}) : super(key: key);

  @override
  State<TrailItineraryModal> createState() => _TrailItineraryModalState();
}

class _TrailItineraryModalState extends State<TrailItineraryModal> {
  int? _selectedExperienceId;
  int _currentDayIndex = 0;

  List<Widget> _buildItineraryList(PreviewTrailModel model) {
    List<Widget> itineraryList = [];
    if (model.currentTrailPreview.experiences.isEmpty) return itineraryList;

    // Sort experiences first so they are in timeline order
    List<Experience> sortedExperiences =
        List.from(model.currentTrailPreview.experiences);
    sortedExperiences
        .sort((a, b) => a.visitStartTime.compareTo(b.visitStartTime));

    Map<int, List<Experience>> daysMap = {};

    // Determine number of days from total estimated time, or default to 1
    int estimatedDays =
        (model.currentTrailPreview.itineraryEstimatedTime.inHours /
                Duration.hoursPerDay)
            .ceil();
    if (estimatedDays < 1) {
      estimatedDays = 1;
    }

    int totalExperiences = sortedExperiences.length;
    // How many experiences per day roughly?
    double experiencesPerDay = totalExperiences / estimatedDays;
    if (experiencesPerDay < 1) experiencesPerDay = 1.0;

    for (int i = 0; i < totalExperiences; i++) {
      var exp = sortedExperiences[i];

      // Group them sequentially according to the estimated duration of the whole trail
      int dayKey = (i / experiencesPerDay).floor();

      // Safety cap so we don't exceed the estimated days (0-indexed)
      if (dayKey >= estimatedDays) {
        dayKey = estimatedDays - 1;
      }

      daysMap.putIfAbsent(dayKey, () => []).add(exp);
    }

    var sortedKeys = daysMap.keys.toList()..sort();
    if (sortedKeys.isEmpty) return itineraryList;

    // Ensure _currentDayIndex is within bounds
    if (_currentDayIndex >= sortedKeys.length) {
      _currentDayIndex = sortedKeys.length - 1;
    }
    if (_currentDayIndex < 0) {
      _currentDayIndex = 0;
    }

    int currentDayKey = sortedKeys[_currentDayIndex];
    int dayNumber = currentDayKey + 1;
    List<Experience> dayEvents = daysMap[currentDayKey]!;

    itineraryList.add(
      Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 32,
              color: _currentDayIndex > 0 ? tealish : Colors.grey[400],
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentDayIndex > 0
                  ? () {
                      setState(() {
                        _currentDayIndex--;
                      });
                    }
                  : null,
            ),
            Text(
              'Day $dayNumber',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1D1F),
              ),
            ),
            IconButton(
              iconSize: 32,
              color: _currentDayIndex < sortedKeys.length - 1
                  ? tealish
                  : Colors.grey[400],
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentDayIndex < sortedKeys.length - 1
                  ? () {
                      setState(() {
                        _currentDayIndex++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );

    dayEvents.sort((Experience a, Experience b) =>
        a.visitStartTime.compareTo(b.visitStartTime));

    List<dynamic> itemsToRender = List.from(dayEvents);

    for (int j = 0; j < itemsToRender.length; j++) {
      var item = itemsToRender[j];
      bool isNextMealOrSleep = false;
      if (j < itemsToRender.length - 1) {
        var nextItem = itemsToRender[j + 1];
        if ((nextItem is Map && nextItem['type'] == 'meal') ||
            (nextItem is Map && nextItem['type'] == 'sleep')) {
          isNextMealOrSleep = true;
        } else if (nextItem is Experience &&
            (nextItem.accommodation || nextItem.foodDrinks)) {
          isNextMealOrSleep = true;
        }
      }

      if (item is Experience) {
        if (item.accommodation || item.foodDrinks) {
          itineraryList.add(ItineraryMealSleepBlock(
            experience: item,
            isMeal: item.foodDrinks,
          ));
        } else {
          itineraryList.add(ItineraryExperienceCard(
            experience: item,
            isSelected: _selectedExperienceId == item.experienceId,
            onTap: () {
              setState(() {
                _selectedExperienceId = item.experienceId;
              });
            },
            onViewExperienceTap: () {
              Navigator.pushNamed(
                context,
                '/experience',
                arguments: item,
              );
            },
          ));
        }
      } else if (item is Map) {
        if (item['type'] == 'meal') {
          itineraryList.add(ItineraryMealSleepBlock(
            isMeal: true,
            customName: item['name'],
            customTitle: item['name'],
            customDescription: '${item['duration']} duration',
          ));
        } else if (item['type'] == 'sleep') {
          itineraryList.add(ItineraryMealSleepBlock(
            isMeal: false,
            customName: item['name'],
            customTitle: item['name'],
            customDescription: '${item['duration']} duration',
          ));
        }
      }

      bool isCurrentMealOrSleep = false;
      if ((item is Map && item['type'] == 'meal') ||
          (item is Map && item['type'] == 'sleep')) {
        isCurrentMealOrSleep = true;
      } else if (item is Experience &&
          (item.accommodation || item.foodDrinks)) {
        isCurrentMealOrSleep = true;
      }

      if (j < itemsToRender.length - 1 &&
          !isCurrentMealOrSleep &&
          !isNextMealOrSleep) {
        itineraryList.add(const ItineraryTransitBlock());
      }
    }
    return itineraryList;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Itinerary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F),
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: _buildItineraryList(widget.model),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

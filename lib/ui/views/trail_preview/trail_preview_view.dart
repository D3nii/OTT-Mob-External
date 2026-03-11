// ui/views/trail_preview/trail_preview_view.dart
import 'package:flutter/foundation.dart';
import 'package:onetwotrail/ui/widgets/tab_board_item.dart';
import 'package:onetwotrail/ui/widgets/tab_itinerary_item.dart';
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
import 'package:onetwotrail/ui/share/geo_helpers.dart';
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
          height: mediaQuery.height * 0.16,
          width: mediaQuery.width,
          color: tealish,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  children: [
                    CupertinoBackButton(
                      label: AppLocalizations.of(context)?.backText ?? "Back",
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
                const Spacer(),
                const _ParentTabs(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParentTabs extends StatelessWidget {
  const _ParentTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewTrailModel>(builder: (context, model, _) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 20,
            child: Container(),
          ),
          Expanded(
            flex: 30,
            child: TabBoardItem(
              !model.isItineraryView,
              () {
                model.isItineraryView = false;
              },
            ),
          ),
          Expanded(
            flex: 30,
            child: TabItineraryItem(
              model.isItineraryView,
              () {
                showDialog(
                  context: context,
                  builder: (_) => TrailItineraryModal(model: model),
                ).then((_) {
                  // Reset state if needed or maintain UI consistency
                  model.isItineraryView = false;
                });
              },
            ),
          ),
          Expanded(
            flex: 20,
            child: Container(),
          )
        ],
      );
    });
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
        return StreamBuilder<BaseResponse<User>>(
          initialData: model.profileService.userResponse,
          stream: model.profileService.userResponseStream,
          builder: (context, snapshot) {
            if (model.state == ViewState.Busy) {
              return const Expanded(
                child: Center(child: CircularProgressBar()),
              );
            }

            if (model.showErrorStatus) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        text: AppLocalizations.of(context)!
                            .somethingWentWrongRequestText,
                        children: [
                          const TextSpan(text: ". "),
                          TextSpan(
                            text: AppLocalizations.of(context)!.tryAgain,
                            style: const TextStyle(
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => model.showTrailDetails(
                                  model.currentTrailPreview, true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return Expanded(
              child: Stack(
                children: [
                  _buildBoardView(model),
                  // "Add to my trails" button - visible in both tabs as a footer
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!
                                        .addToMyTrailsText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                            onPressed: () =>
                                model.addCurrentTrailToCollection(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (model.showTrailAdded)
                    AddedToTrail(
                      model.isAdded
                          ? AppLocalizations.of(context)!.trailAddedText
                          : AppLocalizations.of(context)!.deleteText,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBoardView(PreviewTrailModel model) {
    var experienceCount = _showAllExperiences
        ? model.currentTrailPreview.experiences.length
        : (model.currentTrailPreview.experiences.length > 6
            ? 6
            : model.currentTrailPreview.experiences.length);
    if (experienceCount > model.currentTrailPreview.experiences.length) {
      experienceCount = model.currentTrailPreview.experiences.length;
    }

    return ListView(
      key: const PageStorageKey('board_list'),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              mainAxisExtent: 240,
            ),
            itemBuilder: (context, index) {
              var width = MediaQuery.of(context).size.width / 2 - 14;
              var height = MediaQuery.of(context).size.width / 2 - 28;
              var experience = model.currentTrailPreview.experiences[index];
              return experienceItem(
                context: context,
                experience: experience,
                height: height,
                width: width,
                experienceNameFontSize: 12,
                experienceDestinationFontSize: 10,
                onLongPress: doNothing,
                onTap: () {
                  Provider.of<EventClient>(context, listen: false).createEvent(
                      Event(EventName.experience_profile_viewed,
                          EventSourceView.trail_experience, {
                    EventTag.experience_id: experience.experienceId.toString(),
                    EventTag.experience_name: experience.name,
                    EventTag.trail_id: model.currentTrailPreview.id.toString(),
                    EventTag.trail_name: model.currentTrailPreview.name,
                  }));
                },
                showAddToTrailButton: true,
                showMoreOptionsButton: false,
                backgroundColor: const Color(0xFFF5F5F7),
              );
            },
          ),
        ),
        if (model.currentTrailPreview.experiences.length > 6) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: tealish,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showAllExperiences = !_showAllExperiences;
                  });
                },
                child: Text(
                  _showAllExperiences ? 'Show Less' : 'Show More',
                  style: const TextStyle(
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
          AppLocalizations.of(context)!.experiencesOnTheMap,
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
                target: LatLng(model.currentTrailPreview.latitude,
                    model.currentTrailPreview.longitude),
              ),
              onMapCreated: model.onTrailMapCreated,
              markers: model.getMarkers(trail: model.currentTrailPreview),
              polylines: model.polylines,
              gestureRecognizers: Set()
                ..add(Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer())),
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
            itemCount: model.currentTrailPreview.experiences.length > 5
                ? 5
                : model.currentTrailPreview.experiences.length,
            itemBuilder: (context, index) {
              var experience = model.currentTrailPreview.experiences[index];
              var width = MediaQuery.of(context).size.width / 2.5;
              var height = width;
              var itemCount = model.currentTrailPreview.experiences.length > 5
                  ? 5
                  : model.currentTrailPreview.experiences.length;
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
                    Provider.of<EventClient>(context, listen: false)
                        .createEvent(Event(EventName.experience_profile_viewed,
                            EventSourceView.trail_experience, {
                      EventTag.experience_id:
                          experience.experienceId.toString(),
                      EventTag.experience_name: experience.name,
                      EventTag.trail_id:
                          model.currentTrailPreview.id.toString(),
                      EventTag.trail_name: model.currentTrailPreview.name,
                    }));
                  },
                  showAddToTrailButton: false,
                  showMoreOptionsButton: false,
                  backgroundColor: const Color(0xFFF5F5F7),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
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

    List<Experience> sortedExperiences =
        List.from(model.currentTrailPreview.experiences);
    sortedExperiences
        .sort((a, b) => a.visitStartTime.compareTo(b.visitStartTime));

    Map<int, List<Experience>> daysMap = {};
    int estimatedDays =
        (model.currentTrailPreview.itineraryEstimatedTime.inHours /
                Duration.hoursPerDay)
            .ceil();
    if (estimatedDays < 1) estimatedDays = 1;

    int totalExperiences = sortedExperiences.length;
    double experiencesPerDay = totalExperiences / estimatedDays;
    if (experiencesPerDay < 1) experiencesPerDay = 1.0;

    for (int i = 0; i < totalExperiences; i++) {
      var exp = sortedExperiences[i];
      int dayKey = (i / experiencesPerDay).floor();
      if (dayKey >= estimatedDays) dayKey = estimatedDays - 1;
      daysMap.putIfAbsent(dayKey, () => []).add(exp);
    }

    int safeDayIndex = _currentDayIndex;
    if (!daysMap.containsKey(safeDayIndex)) {
      if (daysMap.isNotEmpty) {
        safeDayIndex = daysMap.keys.first;
      } else {
        return itineraryList;
      }
    }

    List<Experience> dayEvents = daysMap[safeDayIndex]!;
    dayEvents.sort((a, b) => a.visitStartTime.compareTo(b.visitStartTime));

    // List of actual visits (excluding existing meal/sleep blocks in the data)
    List<Experience> visits =
        dayEvents.where((e) => !e.foodDrinks && !e.accommodation).toList();

    bool needsBreakfast = visits.any((e) {
      int start =
          e.visitStartTime.toUtc().subtract(const Duration(hours: 6)).hour;
      int end = e.visitEndTime.toUtc().subtract(const Duration(hours: 6)).hour;
      // Overlaps 9 AM - 12 PM
      return start < 12 && end >= 9;
    });
    bool needsLunch = visits.any((e) {
      int start =
          e.visitStartTime.toUtc().subtract(const Duration(hours: 6)).hour;
      int end = e.visitEndTime.toUtc().subtract(const Duration(hours: 6)).hour;
      // Overlaps 12 PM - 8 PM
      return start < 20 && end >= 12;
    });
    bool needsDinner = visits.any((e) {
      int end = e.visitEndTime.toUtc().subtract(const Duration(hours: 6)).hour;
      // Active at or after 8 PM
      return end >= 20;
    });

    bool breakfastAdded = false;
    bool lunchAdded = false;
    bool dinnerAdded = false;

    for (int j = 0; j < dayEvents.length; j++) {
      var exp = dayEvents[j];
      int startHour =
          exp.visitStartTime.toUtc().subtract(const Duration(hours: 6)).hour;
      int endHour =
          exp.visitEndTime.toUtc().subtract(const Duration(hours: 6)).hour;

      // Breakfast: before first visit starting at/after 9, or visit covering 9 AM
      if (needsBreakfast &&
          !breakfastAdded &&
          (startHour >= 9 || endHour >= 9)) {
        itineraryList.add(const ItineraryMealSleepBlock(
          isMeal: true,
          customName: 'Breakfast',
          customDescription: '30 minutes',
        ));
        breakfastAdded = true;
      }

      // Lunch: before first visit starting at/after 12, or visit covering 12 PM
      if (needsLunch && !lunchAdded && (startHour >= 12 || endHour >= 12)) {
        itineraryList.add(const ItineraryMealSleepBlock(
          isMeal: true,
          customName: 'Lunch',
          customDescription: '30 minutes',
        ));
        lunchAdded = true;
      }

      // Dinner: before first visit starting at/after 20 (8 PM), or visit covering 8 PM
      if (needsDinner && !dinnerAdded && (startHour >= 20 || endHour >= 20)) {
        itineraryList.add(const ItineraryMealSleepBlock(
          isMeal: true,
          customName: 'Dinner',
          customDescription: '30 minutes',
        ));
        dinnerAdded = true;
      }

      if (exp.foodDrinks || exp.accommodation) {
        itineraryList.add(ItineraryMealSleepBlock(
          experience: exp,
          isMeal: exp.foodDrinks,
        ));
      } else {
        itineraryList.add(ItineraryExperienceCard(
          experience: exp,
          isSelected: _selectedExperienceId == exp.experienceId,
          onTap: () {
            setState(() {
              _selectedExperienceId = exp.experienceId;
            });
          },
          onViewExperienceTap: () {
            Navigator.pushNamed(
              context,
              '/experience',
              arguments: exp,
            );
          },
        ));
      }

      if (j < dayEvents.length - 1) {
        var nextExp = dayEvents[j + 1];

        // 1. Convert start_time and end_time to Costa Rica local time (UTC-6)
        DateTime startCR =
            exp.visitEndTime.toUtc().subtract(const Duration(hours: 6));
        DateTime endCR =
            nextExp.visitStartTime.toUtc().subtract(const Duration(hours: 6));

        // 2. Calculate difference in milliseconds
        int durationMs = endCR.difference(startCR).inMilliseconds;

        // 3. Convert to total minutes
        double totalMinutes = durationMs / (1000 * 60);

        // FALLBACK: If time gap is 0 or less, calculate based on distance
        if (totalMinutes <= 0) {
          double distanceKm = GeoHelpers.calculateDistance(
              exp.latitude, exp.longitude, nextExp.latitude, nextExp.longitude);
          // Estimate 2.5 minutes per km for Costa Rica (approx 24 km/h avg)
          totalMinutes = distanceKm * 2.5;
        }

        // 4. Round up to nearest 10 minutes
        int roundedMinutes = (totalMinutes / 10).ceil() * 10;

        // Ensure at least 10 minutes if they are not at the same location
        if (roundedMinutes == 0 &&
            (exp.latitude != nextExp.latitude ||
                exp.longitude != nextExp.longitude)) {
          roundedMinutes = 10;
        }

        // 5. Human-readable display format
        String durationStr;
        int hours = roundedMinutes ~/ 60;
        int mins = roundedMinutes % 60;

        if (hours > 0) {
          durationStr =
              '$hours ${hours == 1 ? 'hour' : 'hours'} $mins ${mins == 1 ? 'minute' : 'minutes'}';
        } else {
          durationStr = '$mins ${mins == 1 ? 'minute' : 'minutes'}';
        }

        itineraryList.add(ItineraryTransitBlock(
          transportType: 'car',
          duration: durationStr,
        ));
      }
    }

    // Fallback if windows passed without triggers (e.g. dinner is at the very end)
    if (needsLunch && !lunchAdded) {
      itineraryList.add(const ItineraryMealSleepBlock(
          isMeal: true, customName: 'Lunch', customDescription: '30 minutes'));
    }
    if (needsDinner && !dinnerAdded) {
      itineraryList.add(const ItineraryMealSleepBlock(
          isMeal: true, customName: 'Dinner', customDescription: '30 minutes'));
    }

    itineraryList.add(const ItineraryMealSleepBlock(
      isMeal: false,
      customName: 'Sleep',
      customDescription: '8 hours',
    ));

    return itineraryList;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> itineraryItems = _buildItineraryList(widget.model);

    int totalDays =
        (widget.model.currentTrailPreview.itineraryEstimatedTime.inHours /
                Duration.hoursPerDay)
            .ceil();
    if (totalDays < 1) totalDays = 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            // Map at the top
            SizedBox(
              height: 200,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.model.currentTrailPreview.latitude,
                      widget.model.currentTrailPreview.longitude),
                ),
                onMapCreated: widget.model.onTrailMapCreated,
                markers: widget.model.getMarkers(
                    trail: widget.model.currentTrailPreview,
                    selectedExperienceId: _selectedExperienceId),
                polylines: widget.model.polylines,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                gestureRecognizers: Set()
                  ..add(Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer())),
              ),
            ),
            // Expanded content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: itineraryItems,
              ),
            ),
            // Footer with navigation and close
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 28,
                          color:
                              _currentDayIndex > 0 ? tealish : Colors.grey[400],
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentDayIndex > 0
                              ? () {
                                  setState(() {
                                    _currentDayIndex--;
                                  });
                                }
                              : null,
                        ),
                        const SizedBox(width: 32),
                        Text(
                          'Day ${_currentDayIndex + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(width: 32),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 28,
                          color: _currentDayIndex < totalDays - 1
                              ? tealish
                              : Colors.grey[400],
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentDayIndex < totalDays - 1
                              ? () {
                                  setState(() {
                                    _currentDayIndex++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close,
                            color: Colors.grey, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

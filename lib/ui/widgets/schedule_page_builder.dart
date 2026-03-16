import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/transit_itinerary_event.dart';
import 'package:onetwotrail/repositories/models/visit_itinerary_event.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/repositories/viewModels/schedule_page_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:onetwotrail/ui/widgets/show_dialog_mark_experience_as_done.dart';
import 'package:onetwotrail/v2/util/string.dart';
import 'package:provider/provider.dart';
import 'package:onetwotrail/ui/views/trail_preview/itinerary_widgets.dart';

// This file has been converted from functional widgets to class-based widgets
// for Flutter 3 compatibility

class SchedulePageBuilder extends StatelessWidget {
  const SchedulePageBuilder({Key? key}) : super(key: key);

  // Logger instance for this class
  static final Logger _logger = Logger('SchedulePageBuilder');

  @override
  Widget build(BuildContext context) {
    // Log when the build method is called
    _logger.info('Building');

    return ChangeNotifierProxyProvider<Itinerary, SchedulePageViewModel>(
      create: (context) {
        var boardAndItineraryModel =
            Provider.of<ControllerPageBoardAndItineraryModel>(context,
                listen: false);
        var itinerary = Provider.of<Itinerary>(context, listen: false);
        var trailService = Provider.of<TrailService>(context, listen: false);

        // Log the itinerary that's being used to create the model
        _logger.info('Creating model with itinerary ID: ${itinerary.id}');

        var model = SchedulePageViewModel(
            boardAndItineraryModel, itinerary, trailService);
        model.init(context);
        return model;
      },
      update: (context, itinerary, model) {
        // Log when the update method is called and what itinerary it's receiving
        _logger.info('Updating with itinerary ID: ${itinerary.id}');

        // Always create a new model when the itinerary changes
        // This ensures the model has the latest itinerary data
        _logger.info('Creating new model with updated data');
        var newModel = SchedulePageViewModel(
            Provider.of<ControllerPageBoardAndItineraryModel>(context,
                listen: false),
            itinerary,
            Provider.of<TrailService>(context, listen: false));
        newModel.init(context);
        return newModel;
      },
      child: Consumer<SchedulePageViewModel>(
        builder: (context, model, _) {
          Size mediaQuery = MediaQuery.of(context).size;
          return SizedBox(
              height: mediaQuery.height - mediaQuery.height * 0.20,
              width: mediaQuery.width,
              child: PageView.builder(
                  allowImplicitScrolling: false,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  controller: model.listViewItineraryController,
                  itemCount: model.scheduleDays.length,
                  itemBuilder:
                      (BuildContext context, int indexOfDayInSchedule) {
                    List? dayList = model.scheduleDays[model.scheduleDays.keys
                        .elementAt(indexOfDayInSchedule)];
                    if (dayList == null) {
                      return Container();
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ScrollContainer(
                            indexOfDayInSchedule, model.scheduleDays.length),
                        Expanded(
                          child: Stack(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 16),
                                itemCount: dayList.length + 1,
                                itemBuilder:
                                    (BuildContext context, int indexOfItem) {
                                  if (indexOfItem == dayList.length) {
                                    return const SizedBox(height: 100);
                                  }
                                  if (dayList[indexOfItem]
                                      is VisitItineraryEvent) {
                                    VisitItineraryEvent event =
                                        dayList[indexOfItem]
                                            as VisitItineraryEvent;

                                    if (event.experience.experienceId == -1) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: ItineraryMealSleepBlock(
                                          experience: event.experience,
                                          isMeal: event.experience.foodDrinks,
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Slidable(
                                        key: ValueKey(event.experience.experienceInTrailId),
                                        endActionPane: ActionPane(
                                          motion: const DrawerMotion(),
                                          extentRatio: 0.35,
                                          children: [
                                            if (event.experience.visited)
                                              CustomSlidableAction(
                                                onPressed: (context) async {
                                                  var success = await model.markExperienceAsNotVisited(
                                                      context, event.experience.experienceInTrailId);
                                                  if (success) await model.init(context);
                                                },
                                                backgroundColor: Colors.grey,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.all(8),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.close, color: Colors.white),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      AppLocalizations.of(context)?.markAsNotVisited ??
                                                          "Mark as not visited",
                                                      textAlign: TextAlign.center,
                                                      style:
                                                          TextStyle(color: Colors.white, fontSize: 13),
                                                      maxLines: 4,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              CustomSlidableAction(
                                                onPressed: (context) {
                                                  showDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    useSafeArea: false,
                                                    builder: (BuildContext context) =>
                                                        ShowDialogExperienceMarkAsDone(
                                                      event.experience.experienceInTrailId,
                                                      model.itinerary.id,
                                                      event.experience,
                                                    ),
                                                  ).then((value) => model.init(context));
                                                },
                                                backgroundColor: tealish,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.all(8),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.check, color: Colors.white),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      AppLocalizations.of(context)?.markAsVisited ??
                                                          "Mark as visited",
                                                      textAlign: TextAlign.center,
                                                      style:
                                                          TextStyle(color: Colors.white, fontSize: 13),
                                                      maxLines: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        child: ItineraryExperienceCard(
                                          experience: event.experience,
                                          isVisited: event.experience.visited,
                                          onTap: () {},
                                          onViewExperienceTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Provider.value(
                                                  value: event.experience,
                                                  child: ExperienceInfo(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                  if (dayList[indexOfItem]
                                      is TransitItineraryEvent) {
                                    TransitItineraryEvent item =
                                        dayList[indexOfItem]
                                            as TransitItineraryEvent;


                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: ItineraryTransitBlock(
                                        transportType: 'car',
                                        duration: item.duration.inMinutes > 0
                                            ? '${item.duration.inMinutes} mins'
                                            : null,
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      UIHelper.verticalSpace(32),
                                      MapButton(dayList, indexOfDayInSchedule),
                                      UIHelper.verticalSpace(32)
                                    ]),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }));
        },
      ),
    );
  }
}

class ScrollContainer extends StatelessWidget {
  final int index;
  final int length;

  const ScrollContainer(this.index, this.length, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SchedulePageViewModel>(
      builder: (context, model, _) {
        Size mediaQuery = MediaQuery.of(context).size;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(color: tealish.withOpacity(0.3), width: 1)),
          ),
          height: mediaQuery.height * 0.062,
          width: mediaQuery.width,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 10,
                  child: IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: index == 0 ? Colors.grey[400] : tealish,
                      size: 24,
                    ),
                    onPressed: () {
                      model.previousPageTrailView(index);
                    },
                  )),
              Expanded(
                flex: 30,
                child: Container(
                  alignment: Alignment.center,
                  // Number of the day in the schedule
                  child: Text(
                    "${capitalizeFirstLetter(AppLocalizations.of(context)?.day ?? "Day")}: ${index + 1}",
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F)),
                  ),
                ),
              ),
              Expanded(
                flex: 50,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/calendar.png',
                        color: tomato,
                      ),
                      Container(
                        width: 16,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child:
                            Text("${model.scheduleDays.keys.elementAt(index)}"),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 10,
                  child: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: index == length - 1 ? Colors.grey[400] : tealish,
                      size: 24,
                    ),
                    onPressed: () {
                      model.nextPageTrailView(index);
                    },
                  ))
            ],
          ),
        );
      },
    );
  }
}

class MapButton extends StatelessWidget {
  final List dayActivities;
  final int selectedDayIndex;

  const MapButton(this.dayActivities, this.selectedDayIndex, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<SchedulePageViewModel,
        ControllerPageBoardAndItineraryModel>(
      builder: (context, model, controllerPageBoardAndItineraryModel, _) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: viridian,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/map.png',
                  color: Colors.white,
                  height: 14,
                  width: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)?.mapText ?? "Map",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            onPressed: () {
              controllerPageBoardAndItineraryModel.loadMapActivities(
                  model.scheduleDays, selectedDayIndex);
              controllerPageBoardAndItineraryModel.showItineraryMap =
                  true;
            },
          ),
        );
      },
    );
  }
}

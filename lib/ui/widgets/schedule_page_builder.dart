import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/transit_itinerary_event.dart';
import 'package:onetwotrail/repositories/models/visit_itinerary_event.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/repositories/viewModels/schedule_page_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:onetwotrail/ui/widgets/itinerary_experience_item.dart';
import 'package:onetwotrail/ui/widgets/show_dialog_mark_experience_as_done.dart';
import 'package:onetwotrail/utils/show_dialog_maps.dart';
import 'package:onetwotrail/v2/util/string.dart';
import 'package:provider/provider.dart';

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
        var boardAndItineraryModel = Provider.of<ControllerPageBoardAndItineraryModel>(context, listen: false);
        var itinerary = Provider.of<Itinerary>(context, listen: false);
        var trailService = Provider.of<TrailService>(context, listen: false);

        // Log the itinerary that's being used to create the model
        _logger.info('Creating model with itinerary ID: ${itinerary.id}');

        var model = SchedulePageViewModel(boardAndItineraryModel, itinerary, trailService);
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
          Provider.of<ControllerPageBoardAndItineraryModel>(context, listen: false),
          itinerary,
          Provider.of<TrailService>(context, listen: false)
        );
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
                  itemBuilder: (BuildContext context, int indexOfDayInSchedule) {
                    List? dayList = model.scheduleDays[model.scheduleDays.keys.elementAt(indexOfDayInSchedule)];
                    if (dayList == null) {
                      return Container();
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ScrollContainer(indexOfDayInSchedule, model.scheduleDays.length),
                        Expanded(
                          child: Stack(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: dayList.length + 1,
                                itemBuilder: (BuildContext context, int indexOfItem) {
                                  if (indexOfItem == dayList.length) {
                                    return Container(
                                      height: 128,
                                    );
                                  }
                                  if (dayList[indexOfItem] is VisitItineraryEvent) {
                                    return ItineraryExperienceContainer(dayList[indexOfItem] as VisitItineraryEvent);
                                  }
                                  if (dayList[indexOfItem] is TransitItineraryEvent) {
                                    TransitItineraryEvent item = dayList[indexOfItem] as TransitItineraryEvent;
                                    return TimeToTheOtherExperienceContainer(
                                        item.duration, indexOfItem == (dayList.length - 1));
                                  }
                                  return Container();
                                },
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
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

class ItineraryExperienceContainer extends StatelessWidget {
  final VisitItineraryEvent event;

  // Use a GlobalKey for the Slidable widget to ensure we can access it from anywhere
  const ItineraryExperienceContainer(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    // Create a GlobalKey that will be accessible throughout the widget tree
    final slidableKey = GlobalKey();
    var padding = mediaQuery.width * 0.055;
    return Consumer<SchedulePageViewModel>(builder: (context, model, _) {
      return Column(
        children: [
          Container(
            height: mediaQuery.height * 0.04,
            width: mediaQuery.width,
            padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.055),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 50,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      DateFormat('hh:mmaaa').format(event.startTime),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                ),
                Flexible(
                  flex: 50,
                  child: Container(
                    padding: EdgeInsets.only(right: 5),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Container(
                            width: 15,
                            height: 15,
                            child: Image.asset(
                              'assets/icons/clock.png',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(child: Text(_formatEventDuration(event.duration)))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          event.experience.visited
              ? Slidable(
                  key: slidableKey,
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.35,
                    children: [
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
                              AppLocalizations.of(context)?.markAsNotVisited ?? "Mark as not visited",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 13),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  child: _slidableChildContainer(event, padding, () {
                    final controller = Slidable.of(context);
                    if (controller != null) {
                      if (controller.actionPaneType.value != ActionPaneType.none) {
                        controller.close();
                      } else {
                        controller.openEndActionPane();
                      }
                    }
                  }),
                )
              : Slidable(
                  key: slidableKey,
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.35,
                    children: [
                      CustomSlidableAction(
                        onPressed: (context) {
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            useSafeArea: false,
                            builder: (BuildContext context) => ShowDialogExperienceMarkAsDone(
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
                              AppLocalizations.of(context)?.markAsVisited ?? "Mark as visited",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 13),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  child: _slidableChildContainer(event, padding, () {
                    final controller = Slidable.of(context);
                    if (controller != null) {
                      if (controller.actionPaneType.value != ActionPaneType.none) {
                        controller.close();
                      } else {
                        controller.openEndActionPane();
                      }
                    }
                  }),
                )
        ],
      );
    });
  }
}

Widget _slidableChildContainer(
  VisitItineraryEvent scheduleExperienceItem,
  double padding,
  VoidCallback onMoreTap,
) {
  return Consumer<SchedulePageViewModel>(
    builder: (context, model, _) {
      final BuildContext capturedContext = context;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: OpenContainer(
                transitionDuration: Duration(milliseconds: 500),
                transitionType: ContainerTransitionType.fade,
                closedElevation: 0,
                closedColor: Colors.transparent,
                openColor: Color(0xfff9f9f9),
                closedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(color: Colors.transparent, style: BorderStyle.none)),
                openBuilder: (context, _) => Provider.value(
                  value: scheduleExperienceItem.experience,
                  child: ExperienceInfo(),
                ),
                closedBuilder: (context, openContainer) => Provider<Experience>.value(
                  value: scheduleExperienceItem.experience,
                  child: scheduleExperienceItem.experience.visited
                      ? ItineraryExperienceItem(
                          height: MediaQuery.of(context).size.height * 0.20,
                          onMoreTap: () {
                            final slidable = Slidable.of(capturedContext);
                            if (slidable != null) {
                              if (slidable.actionPaneType.value != ActionPaneType.none) {
                                slidable.close();
                              } else {
                                slidable.openEndActionPane();
                              }
                            }
                          },
                          onGoNowTap: () {}, // Adding required parameter
                        )
                      : ItineraryExperienceItem(
                          height: MediaQuery.of(context).size.height * 0.20,
                          onGoNowTap: () {
                            ShowDialogMaps().showDialogMapsTrails(context, scheduleExperienceItem.experience, () {
                              Navigator.pop(context);
                            });
                          },
                          onMoreTap: () {
                            final slidable = Slidable.of(capturedContext);
                            if (slidable != null) {
                              if (slidable.actionPaneType.value != ActionPaneType.none) {
                                slidable.close();
                              } else {
                                slidable.openEndActionPane();
                              }
                            }
                          },
                        ),
                ),
              ))
        ],
      );
    },
  );
}

String _formatEventDuration(Duration duration) {
  if (duration.inHours > 0) {
    return "${duration.inHours}h ";
  }
  return "${duration.inMinutes}m ";
}

class MiniThreeDots extends StatelessWidget {
  const MiniThreeDots({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65 / 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: tealish),
            ),
          ),
          Expanded(
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: tealish),
            ),
          ),
          Expanded(
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: tealish),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeToTheOtherExperienceContainer extends StatelessWidget {
  final Duration duration;
  final bool lastTime;

  const TimeToTheOtherExperienceContainer(this.duration, this.lastTime, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: mediaQuery.height * 0.02,
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MiniThreeDots(),
            UIHelper.verticalSpace(10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CartWithTime(duration),
              UIHelper.horizontalSpace(5),
            ]),
            Text(
              lastTime
                  ? AppLocalizations.of(context)?.untilTomorrowTimeText ?? "Until tomorrow"
                  : AppLocalizations.of(context)?.travelTimeText ?? "Travel time",
              style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
            ),
            UIHelper.verticalSpace(10),
            MiniThreeDots()
          ],
        ),
      ),
    );
  }
}

class CartWithTime extends StatelessWidget {
  final Duration duration;

  const CartWithTime(this.duration, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
      height: mediaQuery.height * (0.118 / 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset(
              'assets/icons/car.png',
              color: tealish,
            ),
          ),
          UIHelper.horizontalSpace(3),
          Container(
            child: Text(
              "${DateFormat.Hm().format(DateTime(1970).add(duration))}",
              style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
            ),
          )
        ],
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
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tealish, width: 2))),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
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
                        child: Text("${model.scheduleDays.keys.elementAt(index)}"),
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

  const MapButton(this.dayActivities, this.selectedDayIndex, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<SchedulePageViewModel, ControllerPageBoardAndItineraryModel>(
      builder: (context, model, controllerPageBoardAndItineraryModel, _) {
        return Container(
          height: 50,
          child: Row(
            children: [
              Flexible(
                flex: 60,
                child: Container(),
              ),
              Flexible(
                flex: 40,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: viridian,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: 30,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              'assets/icons/map.png',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 70,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)?.mapText ?? "Map",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      controllerPageBoardAndItineraryModel.loadMapActivities(model.scheduleDays, selectedDayIndex);
                      controllerPageBoardAndItineraryModel.showItineraryMap = true;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExperienceImage extends StatelessWidget {
  final Experience experience;

  const ExperienceImage(this.experience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
        height: mediaQuery.height * 0.13,
        width: mediaQuery.width * 0.285,
        decoration: BoxDecoration(
          color: grey125Color,
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
        child: _checkImageLength(experience.imageUrls)
            ? Stack(children: [
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(11)),
                    child: Image.network(
                      experience.imageUrls[0],
                      fit: BoxFit.fill,
                      width: mediaQuery.width * 0.285,
                    )),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    experience.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                )
              ])
            : Container(
                height: mediaQuery.height * 0.13,
                width: mediaQuery.width * 0.285,
                decoration: BoxDecoration(
                  color: grey125Color,
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
              ));
  }
}

bool _checkImageLength(List<String> images) {
  return images.isNotEmpty;
}

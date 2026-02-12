import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/config/config.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/repositories/viewModels/trail_map_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/drag_handle.dart';
import 'package:onetwotrail/utils/show_dialog_maps.dart';
import 'package:onetwotrail/v2/util/duration.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class TrailMapView extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel model) {
    Size mediaQuery = MediaQuery.of(context).size;
    return ChangeNotifierProvider<TrailMapViewModel>(
      create: (context) {
        List dayActivities = Provider.of<List>(context, listen: false);
        ControllerPageBoardAndItineraryModel controllerPageBoardAndItineraryModel =
            Provider.of<ControllerPageBoardAndItineraryModel>(context, listen: false);
        Config config = Provider.of<Config>(context, listen: false);
        return TrailMapViewModel(dayActivities, controllerPageBoardAndItineraryModel, config.googleMapsApiKey);
      },
      child: Consumer<TrailMapViewModel>(
        builder: (context, model, _) {
          return Stack(
            children: [
              SnappingSheet(
                controller: model.snappingSheetController,
                lockOverflowDrag: true,
                snappingPositions: [
                  model.snappingSheetPositionCollapsed,
                  model.snappingSheetPositionExpanded,
                ],
                grabbing: GestureDetector(
                  onTap: () {
                    if (model.isExpanded) {
                      model.snappingSheetController.snapToPosition(model.snappingSheetPositionCollapsed);
                    } else {
                      model.snappingSheetController.snapToPosition(model.snappingSheetPositionExpanded);
                    }
                  },
                  child: DragHandle(),
                ),
                sheetBelow: SnappingSheetContent(
                  childScrollController: model.scrollController,
                  sizeBehavior: SheetSizeFill(),
                  draggable: false,
                  child: BottomArea(model.scrollController),
                ),
                onSnapCompleted: (sheetPosition, snappingPosition) {
                  model.isExpanded = snappingPosition == model.snappingSheetPositionExpanded;
                },
                grabbingHeight: 48,
                child: _GoogleMapToShow(),
              ),
              _ExitBotton(close: () {
                model.controllerPageBoardAndItineraryModel.showItineraryMap = false;
              }),
            ],
          );
        },
      ),
    );
  }
}

class BottomArea extends StatelessWidget {
  final ScrollController scrollController;

  const BottomArea(this.scrollController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrailMapViewModel, ControllerPageBoardAndItineraryModel>(
        builder: (context, model, controllerPageBoardAndItineraryModel, _) {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: model.currentExperienceIndex > 0 ? tealish : Colors.grey,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (model.currentExperienceIndex > 0) {
                            model.currentExperienceIndex--;
                            model.moveCameraToExperience(model.currentExperienceIndex);
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            model.experiences.isEmpty ? '' : model.experiences[model.currentExperienceIndex].name,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            model.experiences.isEmpty
                                ? ''
                                : model.experiences[model.currentExperienceIndex].visitTime,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: model.currentExperienceIndex < model.experiences.length - 1 ? tealish : Colors.grey,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (model.currentExperienceIndex < model.experiences.length - 1) {
                            model.currentExperienceIndex++;
                            model.moveCameraToExperience(model.currentExperienceIndex);
                          }
                        },
                        icon: Icon(Icons.arrow_forward_ios),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (!model.isExpanded && details.primaryDelta! < 0) {
                    model.snappingSheetController.snapToPosition(model.snappingSheetPositionExpanded);
                  }
                },
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: Scrollbar(
                    controller: scrollController,
                    thickness: 6.0,
                    radius: Radius.circular(3.0),
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: ListView.builder(
                      padding: EdgeInsets.only(right: 8.0),
                      controller: scrollController,
                      physics: model.isExpanded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                      itemCount: model.experiences.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(0),
                          height: 80,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 25,
                                child: _PinkPoints(index),
                              ),
                              Expanded(
                                flex: 50,
                                child: _TimeWithNameOfTheExperience(index),
                              ),
                              Expanded(
                                flex: 25,
                                child: !model.experiences[index].visited ? _GoNowButtom(index) : Container(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: whiteTwo, width: 1)),
              ),
              child: _EstimatedTime(),
            ),
          ],
        ),
      );
    });
  }
}

class _EstimatedTime extends StatelessWidget {
  const _EstimatedTime({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    // Retrieve the estimated time from the context's trail provider.
    var itineraryEstimatedTime = Provider.of<Trail>(context, listen: false).itineraryEstimatedTime;
    return Consumer<TrailMapViewModel>(
      builder: (context, model, _) {
        return Container(
          width: mediaQuery.width * 0.624,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 50,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)?.estimatedTime ?? "Estimated Time",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                flex: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      child: Image.asset(
                        'assets/icons/clock.png',
                        color: tomato,
                      ),
                    ),
                    UIHelper.horizontalSpace(10),
                    Text(
                      fromDurationToText(context, itineraryEstimatedTime),
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExitBotton extends StatelessWidget {
  final VoidCallback close;

  const _ExitBotton({required this.close, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Navigator.pop(context);
        close();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tomato,
            ),
          ),
          Container(
            height: 60,
            width: 60,
            child: Transform.rotate(
              angle: pi / 4,
              child: Image.asset(
                'assets/icons/add.png',
                color: Colors.white,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeWithNameOfTheExperience extends StatelessWidget {
  final int index;

  const _TimeWithNameOfTheExperience(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TrailMapViewModel>(
      builder: (context, model, _) {
        return GestureDetector(
          // On tap, move camera to the experience location
          onTap: () {
            model.currentExperienceIndex = index;
            model.moveCameraToExperience(index);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              model.experiences[index].isVisitEvent
                  ? Text(
                      "${model.experiences[index].visitTime}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                    )
                  : Container(),
              model.experiences[index].isVisitEvent ? UIHelper.verticalSpace(4) : Container(),
              Text(
                "${model.getStartTime(model.experiences[index].visitStartTime)}",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: model.experiences[index].visited ? Colors.black45 : Colors.black),
              ),
              Text(
                "${model.experiences[index].name}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: model.experiences[index].visited ? Colors.black45 : Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoogleMapToShow extends StatelessWidget {
  const _GoogleMapToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TrailMapViewModel>(
      builder: (context, model, _) {
        Size mediaQuery = MediaQuery.of(context).size;
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: mediaQuery.height - 96,
            width: mediaQuery.width,
            child: Container(
                child: GoogleMap(
              compassEnabled: false,
              rotateGesturesEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              myLocationEnabled: false,
              scrollGesturesEnabled: true,
              polylines: model.polyline,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(9.7489, -83.7534),
                zoom: 6,
              ),
              onMapCreated: (GoogleMapController controller) async {
                await model.init(controller);
                if (model.firstPinned != null) {
                  controller.animateCamera(CameraUpdate.newLatLngZoom(model.firstPinned!, 15));
                }
              },
              markers: model.markers,
            )),
          ),
        );
      },
    );
  }
}

class _GoNowButtom extends StatelessWidget {
  final int indexExperience;

  const _GoNowButtom(this.indexExperience, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrailMapViewModel, BaseWidgetModel>(
      builder: (context, model, baseWidgetModel, _) {
        return Container(
            margin: EdgeInsets.only(right: 16),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: tealish,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
              onPressed: () {
                ShowDialogMaps().showDialogMapsExperience(context, model.experiences[indexExperience], afterLaunch: () {
                  Navigator.pop(context);
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 75,
                    child: Container(
                      child: Text(
                        AppLocalizations.of(context)?.goNowText ?? "Go Now",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}

class _PinkPoints extends StatelessWidget {
  final int index;

  const _PinkPoints(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TrailMapViewModel>(
      builder: (context, model, _) {
        return Container(
          child: index == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 34),
                  child: _BigPointsWhitThreeSmallPointsStart(),
                )
              : index == model.experiences.length - 1
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 34),
                      child: _BigPointsWhitThreeSmallPointsEnd(),
                    )
                  : _BigPointsWhitThreeSmallPointsMiddle(),
        );
      },
    );
  }
}

class _BigPointsWhitThreeSmallPointsEnd extends StatelessWidget {
  const _BigPointsWhitThreeSmallPointsEnd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pigPinkTwo,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pigPinkTwo,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pigPinkTwo,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tealish,
            ),
          ),
        ),
      ],
    );
  }
}

class _BigPointsWhitThreeSmallPointsMiddle extends StatelessWidget {
  const _BigPointsWhitThreeSmallPointsMiddle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tealish,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
      ],
    );
  }
}

class _BigPointsWhitThreeSmallPointsStart extends StatelessWidget {
  const _BigPointsWhitThreeSmallPointsStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tealish,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pigPinkTwo,
          ),
        )
      ],
    );
  }
}

class ListViewExperiences extends StatelessWidget {
  const ListViewExperiences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TrailMapViewModel>(
      builder: (context, model, _) {
        return Container(
          height: 100,
          width: 100,
          color: Colors.red,
        );
      },
    );
  }
}

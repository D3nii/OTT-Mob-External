import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/my_trail_board_and_itinerary/board_view.dart';
import 'package:onetwotrail/ui/views/my_trail_board_and_itinerary/trail_itinerary_view.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:onetwotrail/ui/widgets/show_dialog_component_delete_trail.dart';
import 'package:onetwotrail/ui/widgets/tab_board_item.dart';
import 'package:onetwotrail/ui/widgets/tab_itinerary_item.dart';
import 'package:onetwotrail/utils/my_trail_sub_menu_more_helper.dart';
import 'package:provider/provider.dart';

class TabHandler extends ChangeNotifier {
  bool _showBoard = true;
  bool _showItinerary = false;

  bool get showBoard => _showBoard;

  bool get showItinerary => _showItinerary;

  set showItinerary(bool value) {
    _showItinerary = value;
    notifyListeners();
  }

  set showBoard(bool value) {
    _showBoard = value;
    notifyListeners();
  }
}

class TrailView extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseWidgetModel) {
    return ChangeNotifierProvider<TabHandler>(
        create: (_) => TabHandler(),
        child: Consumer<TabHandler>(
            builder: (context, tabHandler, _) => ChangeNotifierProvider<ControllerPageBoardAndItineraryModel>(
                  create: (context) {
                    var trail = Provider.of<Trail>(context, listen: false);
                    var trailService = Provider.of<TrailService>(context, listen: false);
                    var model = ControllerPageBoardAndItineraryModel(context, trailService, trail);
                    model.loadBoardData(true);
                    return model;
                  },
                  child: Consumer<ControllerPageBoardAndItineraryModel>(
                    builder: (context, model, _) {
                      Size mediaQuery = MediaQuery.of(context).size;
                      return Scaffold(
                        backgroundColor: Colors.white,
                        body: Padding(
                          padding: const EdgeInsets.all(0),
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: SizedBox(
                              height: mediaQuery.height,
                              width: mediaQuery.width,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppBarContainer(
                                      () {}, (widgetToShow) => baseWidgetModel.showOverlayWidget(true, widgetToShow)),
                                  !model.isTrailNull()
                                      ? Expanded(
                                          child: PageView(
                                            controller: model.pageController,
                                            physics: NeverScrollableScrollPhysics(),
                                            onPageChanged: (index) {},
                                            children: [
                                              Provider.value(
                                                value: model.trail,
                                                child: BoardView(
                                                  removeExperienceOnTap: (Experience experience) {
                                                    model.removeExperienceTrail(baseWidgetModel, experience);
                                                  },
                                                  addExperienceOnTap: (Experience experience) {
                                                    model.addExperienceTrail(baseWidgetModel, experience);
                                                  },
                                                ),
                                              ),
                                              // The TrailItineraryView now listens directly to the itinerary stream
                                              // from the TrailService, so we don't need a StreamProvider here
                                              TrailItineraryView()
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )));
  }
}

class _ParentTabs extends StatelessWidget {
  final PageController pageController;

  const _ParentTabs(this.pageController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TabHandler>(builder: (context, model, _) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 20,
            child: Container(),
          ),
          Expanded(
            flex: 30,
            child: !model.showBoard
                ? TabBoardItem(false, () {
                    if (pageController.hasClients) {
                      pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                    }
                    model.showBoard = true;
                    model.showItinerary = false;
                  })
                : TabBoardItem(true, () {}),
          ),
          Expanded(
            flex: 30,
            child: !model.showItinerary
                ? TabItineraryItem(false, () {


                    if (pageController.hasClients) {
                      pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
                    }
                    model.showItinerary = true;
                    model.showBoard = false;
                  })
                : TabItineraryItem(model.showItinerary, () {}),
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

void _handleTrailEdit(BuildContext context, Trail trail) {
  MyTrailSubMenuMoreHelper().showEditDialog(
    context,
    trail,
    (result) {
      if (result.result) {
        Trail temp = result.responseObject as Trail;
        trail.name = temp.name;
        trail.description = temp.description;
        trail.collaborators = temp.collaborators;
      }
    },
  );
}

Future<void> _handleItineraryStartDateEdit(BuildContext context, Trail trail, ControllerPageBoardAndItineraryModel model) async {
  if (trail.itineraryId <= 0) {
    return;
  }

  final trailService = Provider.of<TrailService>(context, listen: false);
  final itineraryResponse = trailService.currentItineraryResponse;

  if (itineraryResponse == null || !itineraryResponse.result || itineraryResponse.responseObject == null) {
    return;
  }

  final itinerary = itineraryResponse.responseObject!;
  DateTime currentStartDate;

  try {
    currentStartDate = DateTime.parse(itinerary.startDate);
  } catch (e) {
    currentStartDate = DateTime.now();
  }

  final selectedDate = await showDatePicker(
    context: context,
    initialDate: currentStartDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 730)),
    helpText: AppLocalizations.of(context)?.selectYourStartDate ?? 'Select your start date',
  );

  if (selectedDate == null) {
    return;
  }

  await model.updateItineraryStartDate(
    selectedDate,
    itinerary.adultParticipantsCount,
    itinerary.teenParticipantsCount,
    itinerary.kidsParticipantsCount,
  );
}

class AppBarContainer extends StatelessWidget {
  final VoidCallback hideShowDialogWidget;
  final Function(Widget widget) showDialogWidget;

  const AppBarContainer(this.hideShowDialogWidget, this.showDialogWidget, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer2<ControllerPageBoardAndItineraryModel, BaseWidgetModel>(
      builder: (context, model, baseWidgetModel, _) {
        return /*AppBar*/ Container(
          padding: EdgeInsets.only(top: 15),
          color: tealish,
          width: mediaQuery.width,
          height: mediaQuery.height * 0.20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 75,
                child: Row(
                  children: [
                    Flexible(
                      flex: 50,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 20,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  return Navigator.pop(context, true);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 80,
                              child: Text(
                                model.trail.name.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        height: 48,
                        padding: EdgeInsets.only(right: mediaQuery.width * 0.03),
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          "assets/icons/edit.png",
                          color: Colors.white,
                          height: 30,
                          width: 30,
                        ),
                      ),
                      onTap: () async {
                        final currentPage = model.pageController.page?.round() ?? 0;
                        
                        if (currentPage == 0) {
                          _handleTrailEdit(context, model.trail);
                        } else if (currentPage == 1) {
                          await _handleItineraryStartDateEdit(context, model.trail, model);
                        }
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 30,
                child: Container(
                    decoration: BoxDecoration(color: tealish, border: Border(top: BorderSide.none)),
                    child: _ParentTabs(model.pageController)),
              )
            ],
          ),
        );
      },
    );
  }
}

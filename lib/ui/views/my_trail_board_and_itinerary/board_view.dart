import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/itinerary.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/board_view_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:onetwotrail/ui/views/my_trail_board_and_itinerary/controller_page_board.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/board_trail_experience_item.dart';
import 'package:onetwotrail/ui/widgets/estimated_time_bar.dart';
import 'package:onetwotrail/ui/widgets/experiences_list_item.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class BoardView extends BaseWidget {
  final void Function(Experience experience)? removeExperienceOnTap;
  final void Function(Experience experience)? addExperienceOnTap;

  BoardView({
    this.removeExperienceOnTap,
    this.addExperienceOnTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseWidgetModel) {
    Size mediaQuery = MediaQuery.of(context).size;
    return ChangeNotifierProxyProvider2<TrailService, ControllerPageBoardAndItineraryModel, BoardViewModel>(
      create: (_) => BoardViewModel(),
      update: (_, trailService, boardModel, model) {
        if (model != null) {
          model.context = context;
          model.trailService = trailService;
          model.controllerPageBoard = boardModel;
        }
        return model ?? BoardViewModel();
      },
      child: Consumer2<BoardViewModel, TabHandler>(
        builder: (context, model, tabHandler, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: <Widget>[
                Container(
                  child: EstimatedTimeBar(
                      model.controllerPageBoard.duration, model.controllerPageBoard.updatingBoard),
                ),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: model.controllerPageBoard.showGenerateItineraryButton ? 1.0 : 0.0,
                    duration: Duration(milliseconds: model.controllerPageBoard.showGenerateItineraryAnimDuration),
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                          children: <Widget>[
                            StreamBuilder<List<Experience>>(
                              stream: model.controllerPageBoard.boardExperiences,
                              builder: (context, AsyncSnapshot<List<Experience>> snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Text(
                                      "No experiences",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                                    ),
                                  );
                                }

                                final int count = snapshot.data?.length ?? 0;

                                if (count == 0) {
                                  return Center(
                                    child: Text(
                                      "No experiences",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: StaggeredGrid.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16.0,
                                    crossAxisSpacing: 16.0,
                                    children: List.generate(count, (index) {
                                    final Experience experience = snapshot.data![index];
                                    return StaggeredGridTile.fit(
                                      crossAxisCellCount: 1,
                                      child: Provider<Experience>.value(
                                        key: ValueKey(experience.name),
                                        value: experience,
                                        child: OpenContainer(
                                          transitionDuration: Duration(milliseconds: 500),
                                          transitionType: ContainerTransitionType.fade,
                                          tappable: true,
                                          closedElevation: 0,
                                          closedColor: Color(0xfff9f9f9),
                                          openColor: Color(0xfff9f9f9),
                                          closedShape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                              side: BorderSide(color: Colors.blue, style: BorderStyle.none)),
                                          openBuilder: (context, _) => Provider.value(
                                            value: experience,
                                            child: ExperienceInfo(),
                                          ),
                                          closedBuilder: (context, openContainer) => Provider.value(
                                            value: experience,
                                            child: ExperiencesListItem(
                                              key: ValueKey(experience.experienceId),
                                              moreMenu: (experiences) {},
                                              showElipisisIcon: false,
                                              showMinusIcon: true,
                                              showPlusIcon: false,
                                              minusMenu: (Experience experience) {
                                                removeExperienceOnTap?.call(experience);
                                              },
                                              plusMenu: (experience) {},
                                              openContainer: () => openContainer(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  ),
                                );
                              },
                            ),
                            StreamBuilder<List<Experience>>(
                              stream: model.controllerPageBoard.recentRemoved,
                              builder: (context, AsyncSnapshot<List<Experience>> snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }

                                final int count = snapshot.data?.length ?? 0;

                                if (count == 0) {
                                  return Container();
                                }

                                return ExpansionTile(
                                  title: Container(
                                    child: Container(
                                      padding: EdgeInsets.only(top: 5),
                                      width: double.infinity,
                                      height: mediaQuery.height * 0.042,
                                      child: Text(
                                        "Recently removed",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  onExpansionChanged: model.onExpansionChanged,
                                  initiallyExpanded: true,
                                  trailing: ImageIcon(
                                    AssetImage(model.suggestedExpanded
                                        ? "assets/icons/expandable_chevron_opened.png"
                                        : "assets/icons/expandable_chevron_closed.png"),
                                    size: 20,
                                    color: carissma,
                                  ),
                                  children: [
                                    Container(
                                      height: 210,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        itemCount: count,
                                        itemBuilder: (context, index) {
                                          final Experience experience = snapshot.data![index];
                                          return Padding(
                                            padding: EdgeInsets.only(right: 16.0),
                                            child: Provider<Experience>.value(
                                              value: experience,
                                              child: BoardTrailExperienceItem(
                                                (experience) {
                                                  addExperienceOnTap?.call(experience);
                                                },
                                                true,
                                                height: 134,
                                                containerWidth: 107,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  ]
                                );
                              },
                            ),
                            Container(
                              height: mediaQuery.height * 0.043,
                            ),
                          ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

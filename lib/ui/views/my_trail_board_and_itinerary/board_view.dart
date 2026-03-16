import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/board_view_model.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:onetwotrail/ui/views/my_trail_board_and_itinerary/controller_page_board.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/estimated_time_bar.dart';
import 'package:onetwotrail/ui/widgets/experiences_list_item.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
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
                if (model.controllerPageBoard.hasUnsavedChanges)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    color: tealish.withOpacity(0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "You have unsaved changes",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6E6E73)),
                        ),
                        TextButton(
                          onPressed: () => model.controllerPageBoard.saveBoardChanges(),
                          style: TextButton.styleFrom(
                            backgroundColor: tealish,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: model.controllerPageBoard.updatingItinerary 
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                        ),
                      ],
                    ),
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
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Text(
                                        "No experiences",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6E6E73)),
                                      ),
                                    ),
                                  );
                                }

                                final List<Experience> experiences = snapshot.data!;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  child: GridView.builder(
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: experiences.length,
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12.0,
                                      mainAxisSpacing: 12.0,
                                      mainAxisExtent: 240,
                                    ),
                                    itemBuilder: (context, index) {
                                      var experience = experiences[index];
                                      return Provider<Experience>.value(
                                        value: experience,
                                        child: OpenContainer(
                                          transitionDuration: const Duration(milliseconds: 500),
                                          transitionType: ContainerTransitionType.fade,
                                          closedElevation: 0,
                                          closedColor: Colors.transparent,
                                          openColor: const Color(0xFFF5F5F7),
                                          closedBuilder: (context, openContainer) => ExperiencesListItem(
                                            key: ValueKey(experience.experienceId),
                                            moreMenu: (experiences) {},
                                            showElipisisIcon: false,
                                            showMinusIcon: true,
                                            showPlusIcon: false,
                                            minusMenu: (Experience exp) {
                                              removeExperienceOnTap?.call(exp);
                                            },
                                            plusMenu: (exp) {},
                                            openContainer: openContainer,
                                          ),
                                          openBuilder: (context, _) => Provider.value(
                                            value: experience,
                                            child: ExperienceInfo(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            StreamBuilder<List<Experience>>(
                              stream: model.controllerPageBoard.recentRemoved,
                              builder: (context, AsyncSnapshot<List<Experience>> snapshot) {
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Container();
                                }

                                final List<Experience> recentlyRemoved = snapshot.data!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                                      child: Text(
                                        "Recently removed",
                                        style: TextStyle(
                                          fontSize: 14, 
                                          fontWeight: FontWeight.w700, 
                                          color: Color(0xFF1D1D1F),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      child: GridView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: recentlyRemoved.length,
                                        shrinkWrap: true,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12.0,
                                          mainAxisSpacing: 12.0,
                                          mainAxisExtent: 240,
                                        ),
                                        itemBuilder: (context, index) {
                                          var experience = recentlyRemoved[index];
                                          return Provider<Experience>.value(
                                            value: experience,
                                            child: ExperiencesListItem(
                                              key: ValueKey("removed_${experience.experienceId}"),
                                              moreMenu: (experiences) {},
                                              showElipisisIcon: false,
                                              showMinusIcon: false,
                                              showPlusIcon: true,
                                              plusMenu: (Experience exp) {
                                                addExperienceOnTap?.call(exp);
                                              },
                                              minusMenu: (exp) {},
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
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

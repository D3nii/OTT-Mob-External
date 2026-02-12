import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/repositories/viewModels/trail_itinerary_view_model.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/trail_map_view.dart';
import 'package:onetwotrail/ui/widgets/circular_progress_bar.dart';
import 'package:onetwotrail/ui/widgets/schedule_page_builder.dart';
import 'package:provider/provider.dart';

class TrailItineraryView extends StatelessWidget {
  const TrailItineraryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the TrailService
    final trailService = Provider.of<TrailService>(context, listen: false);

    return ChangeNotifierProxyProvider<ControllerPageBoardAndItineraryModel, TrailItineraryViewModel>(
      create: (_) {
        final viewModel = TrailItineraryViewModel(trailService);
        viewModel.listenToItineraryChanges();
        return viewModel;
      },
      update: (_, controllerModel, viewModel) {
        // This happens outside the build method
        viewModel!.updateControllerPageBoardAndItineraryModel(controllerModel);
        return viewModel;
      },
      child: Consumer<TrailItineraryViewModel>(
        builder: (context, model, _) {
          Size mediaQuery = MediaQuery.of(context).size;

          return Stack(
            children: [
              SizedBox(
                height: mediaQuery.height,
                width: mediaQuery.width,
                child: (() {
                  // Check if we should show the map view
                  if (model.controllerPageBoardAndItineraryModel?.showItineraryMap == true) {
                    return ChangeNotifierProvider.value(
                        value: model,
                        child: Provider.value(
                            value: model.controllerPageBoardAndItineraryModel!.dayActivities, child: TrailMapView()));
                  }

                  // Get the trail reference
                  final trail = model.controllerPageBoardAndItineraryModel?.trail;

                  // If trail has no experiences, show no itinerary message
                  if (trail != null && trail.experiences.isEmpty) {
                    return NoItineraryMessage(trail);
                  }

                  // If there's no itinerary, show appropriate message
                  if (model.itinerary == null) {
                    // Check if we're loading an itinerary
                    final bool isLoadingItinerary = model.controllerPageBoardAndItineraryModel != null &&
                        model.controllerPageBoardAndItineraryModel!.trail.itineraryId > 0;

                    if (isLoadingItinerary) {
                      return Container(child: Center(child: CircularProgressBar()));
                    }

                    // If we have a trail, show the no itinerary message
                    if (trail != null) {
                      return NoItineraryMessage(trail);
                    }

                    // Otherwise show an error
                    return const ErrorContainerTryAgain();
                  }

                  // If we have a valid itinerary, show the schedule
                  if (model.itinerary!.id > 0) {
                    // Provide the itinerary directly to the SchedulePageBuilder
                    return Provider.value(
                      value: model.itinerary,
                      child: SchedulePageBuilder(),
                    );
                  }

                  // If we have an invalid itinerary but have a trail, show no itinerary message
                  if (trail != null) {
                    return NoItineraryMessage(trail);
                  }

                  // Otherwise show an error
                  return const ErrorContainerTryAgain();
                })(),
              ),
              // Show loading overlay when itinerary is updating
              if (model.controllerPageBoardAndItineraryModel?.updatingItinerary == true)
                Container(
                  color: Colors.black45,
                  height: mediaQuery.height,
                  width: mediaQuery.width,
                  child: Center(child: CircularProgressBar()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class NoItineraryMessage extends StatelessWidget {
  final Trail? trail;

  const NoItineraryMessage([this.trail, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UIHelper.verticalSpace(mediaQuery.height * 0.16),
          Container(
              height: mediaQuery.height * 0.17,
              width: mediaQuery.width * 0.381,
              child: Image.asset('assets/on_boarding_images/inspire.png')),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.addAnExperienceText,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
                  ),
                ),
                UIHelper.verticalSpace(mediaQuery.height * 0.019),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.17),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.generateAnItineraryAfterAddingExperienceText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ErrorContainerTryAgain extends StatelessWidget {
  const ErrorContainerTryAgain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        height: 200,
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        alignment: Alignment.topLeft,
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
                    ..onTap = () {
                      // Leave empty for now
                    })
            ],
          ),
        ),
      ),
    );
  }
}

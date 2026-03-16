import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/config/config.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_board_controller_model.dart';
import 'package:onetwotrail/repositories/viewModels/trail_itinerary_view_model.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
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
      create: (context) {
        final config = Provider.of<Config>(context, listen: false);
        final viewModel = TrailItineraryViewModel(trailService, config.googleMapsApiKey);
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
          return Column(
            children: [
              Expanded(
                child: (() {
                  // Get the trail reference
                  final trail = model.controllerPageBoardAndItineraryModel?.trail;

                  // If trail has no experiences
                  if (trail != null && trail.experiences.isEmpty) {
                    return NoItineraryMessage(trail);
                  }

                  // Loading state
                  if (model.itinerary == null) {
                    final bool isLoadingItinerary = model.controllerPageBoardAndItineraryModel != null &&
                        model.controllerPageBoardAndItineraryModel!.trail.itineraryId > 0;
                    if (isLoadingItinerary) {
                      return const Center(child: CircularProgressBar());
                    }
                    if (trail != null) return NoItineraryMessage(trail);
                    return const ErrorContainerTryAgain();
                  }

                  // Valid Itinerary
                  if (model.itinerary!.id > 0) {
                    return Column(
                      children: [
                        // Map at the top (like TrailPreviewView)
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(trail!.latitude, trail.longitude),
                              zoom: 12,
                            ),
                            onMapCreated: model.onMapCreated,
                            markers: model.markers,
                            polylines: model.polylines,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                          ),
                        ),
                        // Experiences List
                        Expanded(
                          child: Provider.value(
                            value: model.itinerary,
                            child: SchedulePageBuilder(), // For now, we'll still use SchedulePageBuilder but it might need its own UI updates
                          ),
                        ),
                      ],
                    );
                  }

                  if (trail != null) return NoItineraryMessage(trail);
                  return const ErrorContainerTryAgain();
                })(),
              ),
              // Show loading overlay when itinerary is updating
              if (model.controllerPageBoardAndItineraryModel?.updatingItinerary == true)
                const CircularProgressBar(),
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

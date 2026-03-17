// v2/trail/widgets.dart
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/ui/views/trail_preview/trail_preview_view.dart';
import 'package:onetwotrail/v2/util/duration.dart';
import 'package:onetwotrail/v2/widget/banner.dart';
import 'package:onetwotrail/v2/widget/three_squares.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class TrailWidgetFactory {
  static Widget createWidgetFromDisplay(
      BuildContext context, String display, Trail trail) {
    return createTitleThreeSquares(context, trail);
  }

  static PageBanner createPageBanner(Trail trail) {
    var experienceCount = trail.experiences.length;
    var secondaryText = "$experienceCount Experience";
    if (experienceCount > 1) {
      secondaryText += "s";
    }
    List<PageBannerPage> pages = [
      PageBannerPage(
          primaryText: trail.name,
          secondaryText: secondaryText,
          image: trail.imageProviders.first,
          onTap: (BuildContext context) {
            // Navigate to the '/public-trail' named route. Pass the trail as argument.
            Navigator.pushNamed(context, '/public-trail', arguments: trail);
          }),
    ];
    return PageBanner(pages: pages);
  }

  static TitleThreeSquares createTitleThreeSquares(
      BuildContext context, Trail trail) {
    // Convert the duration to a human-readable text for the badge.
    var durationText =
        fromDurationToText(context, trail.itineraryEstimatedTime);

    return TitleThreeSquares(
      titleText: trail.name,
      durationText: durationText,
      headerDescription: trail.description,
      summaryTitleText: "",
      summaryBodyText: "",
      images: trail.imageProviders,
      trailingWidget: KeyedSubtree(
        key: ValueKey('trail_map_${trail.id}'),
        child: _TrailMiniMap(trail: trail),
      ),
      mainAction: (BuildContext context) =>
          Provider.value(value: trail, child: TrailPreviewView()),
      padding: EdgeInsets.only(left: 16, right: 16),
    );
  }
}

class _TrailMiniMap extends StatelessWidget {
  final Trail trail;

  const _TrailMiniMap({Key? key, required this.trail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final experiences = trail.experiences;
    LatLng center;
    Set<Marker> markers = {};
    List<LatLng> polylinePoints = [];

    if (experiences.isNotEmpty) {
      center = LatLng(experiences.first.latitude, experiences.first.longitude);
      markers = experiences
          .map((exp) => Marker(
                markerId: MarkerId('exp_${exp.experienceId}'),
                position: LatLng(exp.latitude, exp.longitude),
              ))
          .toSet();

      // Build a simple route polyline following the experiences order,
      // similar to the itinerary view route.
      polylinePoints = experiences
          .map((exp) => LatLng(exp.latitude, exp.longitude))
          .toList();
    } else {
      center = LatLng(trail.latitude, trail.longitude);
      markers = {
        Marker(
          markerId: MarkerId('trail_${trail.id}'),
          position: center,
        )
      };
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 11,
      ),
      // We don't have access to the shared trail preview model here,
      // so we mirror its behaviour by drawing markers and a simple
      // route polyline from the ordered experiences.
      markers: markers,
      polylines: polylinePoints.length >= 2
          ? {
              Polyline(
                polylineId: const PolylineId('trail_route'),
                points: polylinePoints,
                color: Colors.blueAccent,
                width: 4,
              ),
            }
          : const <Polyline>{},
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }
}

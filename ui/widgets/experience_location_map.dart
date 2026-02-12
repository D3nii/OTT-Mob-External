import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/utils/map_marker_utils.dart';
import 'package:onetwotrail/utils/show_dialog_maps.dart';

class ExperienceLocationMap extends StatelessWidget {
  const ExperienceLocationMap(this.experience) : super();

  final Experience experience;

  bool hasLatLng() {
    return experience.latitude != 0.0 && experience.longitude != 0.0;
  }

  LatLng getExperienceLatLng() {
    return LatLng(experience.latitude, experience.longitude);
  }

  Future<Marker> getExperienceMarker() async {
    BitmapDescriptor markerIcon = await MapMarkerUtils.createPinkMarker();

    return Marker(
      markerId: MarkerId(experience.name),
      position: getExperienceLatLng(),
      icon: markerIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLatLng()) {
      return Container(
        width: double.infinity,
        color: grey125Color,
        child: Center(
          child: Text(
            AppLocalizations.of(context)?.notGeoPointToShowText ?? 'No location to show',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          color: grey125Color,
          child: FutureBuilder<Marker>(
            future: getExperienceMarker(),
            builder: (context, snapshot) {
              // Show a loading indicator while the marker is being created
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(color: pigPinkTwo),
                );
              }

              return GestureDetector(
                onTap: () {
                  ShowDialogMaps().showDialogMapsExperience(context, experience, afterLaunch: () {
                    Navigator.pop(context);
                  });
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: GoogleMap(
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: getExperienceLatLng(),
                      zoom: 12,
                    ),
                    markers: Set<Marker>.from([snapshot.data!]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

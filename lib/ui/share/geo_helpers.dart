import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoHelpers {
  /// Calculates the distance between two points in kilometers using the Haversine formula.
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  static LatLngBounds getMapBoundsFromCoordinates(List<LatLng> coordinates) {
    double x0 = -1000, x1 = 0, y0 = 0, y1 = 0;
    for (LatLng latLng in coordinates) {
      if (x0 == -1000) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }
}

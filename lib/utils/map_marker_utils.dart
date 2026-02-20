// utils/map_marker_utils.dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';

/// Utility class for creating custom map markers
class MapMarkerUtils {
  /// Creates a BitmapDescriptor for a circular red marker with white center
  static Future<BitmapDescriptor> createRedMarker({double size = 32}) async {
    // Create a canvas for drawing the marker
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double width = size;
    final double height = size;
    final double s = size / 24.0; // Scale factor from SVG 24x24 viewbox

    // Draw the pin shape path from map-marker-red.svg
    final Paint pinPaint = Paint()
      ..color = const Color(0xFFFA5252) // Exact fill color from SVG
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path path = Path();
    // Outer shape path from SVG
    path.moveTo(12 * s, 2 * s);
    path.cubicTo(8.13 * s, 2 * s, 5 * s, 5.13 * s, 5 * s, 9 * s);
    path.cubicTo(5 * s, 14.25 * s, 12 * s, 22 * s, 12 * s, 22 * s);
    path.relativeMoveTo(0, 0);
    path.cubicTo(12 * s, 22 * s, 19 * s, 14.25 * s, 19 * s, 9 * s);
    path.cubicTo(19 * s, 5.13 * s, 15.87 * s, 2 * s, 12 * s, 2 * s);
    path.close();

    // Inner hole path from SVG
    final Path hole = Path();
    hole.addOval(Rect.fromCircle(
      center: Offset(12 * s, 9 * s),
      radius: 2.5 * s,
    ));

    // Combine paths to create a transparent center hole (no white)
    final Path finalPath = Path.combine(PathOperation.difference, path, hole);

    canvas.drawPath(finalPath, pinPaint);

    // Convert to image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
          width.toInt(),
          height.toInt(),
        );

    // Convert to bytes
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }

    final Uint8List bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }
}

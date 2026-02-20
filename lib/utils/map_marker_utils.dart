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

    final double radius = width * 0.4;
    final Offset topCenter = Offset(width / 2, radius + 2);

    // Draw the pin shape
    final Paint pinPaint = Paint()
      ..color = const Color(0xFFEF5350) // Clean red color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path path = Path();
    // Start at the bottom tip
    path.moveTo(width / 2, height);

    // Draw the pin body with smooth curves
    path.quadraticBezierTo(
      width * 0.9,
      height * 0.6,
      width / 2 + radius,
      topCenter.dy,
    );

    path.arcToPoint(
      Offset(width / 2 - radius, topCenter.dy),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.quadraticBezierTo(width * 0.1, height * 0.6, width / 2, height);
    path.close();

    canvas.drawPath(path, pinPaint);

    // subtle dark border for definition (no white used)
    final Paint borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..isAntiAlias = true;
    canvas.drawPath(path, borderPaint);

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

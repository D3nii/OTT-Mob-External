import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';

/// Utility class for creating custom map markers
class MapMarkerUtils {
  /// Creates a BitmapDescriptor for a marker with the app's logo as the circle and a pink cone below it
  static Future<BitmapDescriptor> createPinkMarker({double size = 64}) async {
    // Load the logo image
    final ByteData logoData = await rootBundle.load('assets/icons/logo/logo_green.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(logoBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image logoImage = frameInfo.image;

    // Create a canvas for drawing the marker
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Calculate dimensions
    final double logoRadius = size / 3.5; // Make the logo smaller
    final double shadowWidth = 2.0;
    final Offset center = Offset(size / 2, size / 3);

    // Draw shadow for the cone shape
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * 255)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowWidth);

    // Draw only the cone shadow (not the circle)
    final Path coneShadowPath = Path()
      ..moveTo(center.dx - logoRadius * 0.6, center.dy + logoRadius - 3)
      ..lineTo(center.dx, center.dy + logoRadius * 2)
      ..lineTo(center.dx + logoRadius * 0.6, center.dy + logoRadius - 3)
      ..close();

    canvas.drawPath(coneShadowPath, shadowPaint);

    // Draw the cone with pink color
    final Paint pinkPaint = Paint()..color = pigPinkTwo;

    final Path conePath = Path()
      ..moveTo(center.dx - logoRadius * 0.6, center.dy + logoRadius - 3)
      ..lineTo(center.dx, center.dy + logoRadius * 2)
      ..lineTo(center.dx + logoRadius * 0.6, center.dy + logoRadius - 3)
      ..close();

    canvas.drawPath(conePath, pinkPaint);

    // Calculate logo size to fit as the circle part of the marker
    final double aspectRatio = logoImage.width / logoImage.height;
    final double logoWidth = logoRadius * 2;
    final double logoHeight = logoWidth / aspectRatio;

    // Calculate the position to center the logo
    final Rect logoRect = Rect.fromCenter(
      center: center,
      width: logoWidth,
      height: logoHeight,
    );

    // Draw the logo as is (no color filter)
    final Paint logoPaint = Paint();

    canvas.drawImageRect(
      logoImage,
      Rect.fromLTWH(0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
      logoRect,
      logoPaint,
    );

    // Convert to image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    // Convert to bytes
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
    }

    final Uint8List bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }
}

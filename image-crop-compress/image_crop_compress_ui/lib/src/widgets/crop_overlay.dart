import 'package:flutter/material.dart';

/// A widget that draws a dark mask over everything outside the crop area.
class CropOverlay extends StatelessWidget {
  const CropOverlay({
    super.key,
    required this.cropRect,
    required this.imageRect,
    this.overlayColor = const Color(0x99000000),
  });

  /// The absolute pixel rectangle representing the active crop area on screen.
  final Rect cropRect;
  
  /// The absolute pixel rectangle representing the bounds of the image.
  final Rect imageRect;

  /// The color of the overlay mask.
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CropOverlayPainter(
          cropRect: cropRect,
          imageRect: imageRect,
          overlayColor: overlayColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  _CropOverlayPainter({
    required this.cropRect,
    required this.imageRect,
    required this.overlayColor,
  });
  final Rect cropRect;
  final Rect imageRect;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // The overlay is only drawn within the image bounds.
    final backgroundPath = Path()..addRect(imageRect);
    final cropPath = Path()..addRect(cropRect);

    // Combine paths to create a hole where the crop rect is
    final maskPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cropPath,
    );

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.imageRect != imageRect ||
        oldDelegate.overlayColor != overlayColor;
  }
}

import 'package:flutter/material.dart';

/// A widget that draws a dark mask over everything outside the crop area.
class CropOverlay extends StatelessWidget {
  const CropOverlay({
    super.key,
    required this.cropRect,
    this.overlayColor = const Color(0x99000000),
  });

  /// The absolute pixel rectangle representing the active crop area on screen.
  final Rect cropRect;

  /// The color of the overlay mask.
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CropOverlayPainter(
          cropRect: cropRect,
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
    required this.overlayColor,
  });
  final Rect cropRect;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cropPath = Path()..addRect(cropRect);

    // Combine paths to create a hole where the crop rect is
    final maskPath =
        Path.combine(PathOperation.difference, backgroundPath, cropPath);

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.overlayColor != overlayColor;
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that draws the draggable corner handles of the crop area.
class CropHandles extends StatelessWidget {
  /// Creates a [CropHandles] widget.
  const CropHandles({
    super.key,
    required this.cropRect,
    this.handleColor = Colors.white,
    this.handleSizeFactor = 0.1,
    this.handleThicknessFactor = 0.015,
  });

  /// The absolute pixel rectangle representing the active crop area on screen.
  final Rect cropRect;

  /// The color of the handles.
  final Color handleColor;

  /// Visual length of the corner brackets relative to shortest side.
  final double handleSizeFactor;

  /// Stroke width of the corner brackets relative to shortest side.
  final double handleThicknessFactor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CropHandlesPainter(
          cropRect: cropRect,
          handleColor: handleColor,
          handleSizeFactor: handleSizeFactor,
          handleThicknessFactor: handleThicknessFactor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _CropHandlesPainter extends CustomPainter {
  _CropHandlesPainter({
    required this.cropRect,
    required this.handleColor,
    required this.handleSizeFactor,
    required this.handleThicknessFactor,
  });

  final Rect cropRect;
  final Color handleColor;
  final double handleSizeFactor;
  final double handleThicknessFactor;

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamic sizing based on cropRect shortest side
    final shortestSide = min(cropRect.width, cropRect.height);
    final handleSize = max(
      shortestSide * handleSizeFactor,
      16.0,
    ); // minimum 16px length
    final handleThickness = max(
      shortestSide * handleThicknessFactor,
      2.0,
    ); // minimum 2px thickness

    final paint = Paint()
      ..color = handleColor
      ..strokeWidth = handleThickness
      ..style = PaintingStyle.stroke;

    final length = handleSize;
    final halfStroke = handleThickness / 2;

    // Top Left Corner
    final tl = cropRect.topLeft;
    final tlPath = Path()
      ..moveTo(tl.dx + length, tl.dy)
      ..lineTo(
        tl.dx - halfStroke,
        tl.dy,
      ) // extending slightly so corners join nicely
      ..lineTo(tl.dx - halfStroke, tl.dy + length);
    canvas.drawPath(tlPath, paint);

    // Top Right Corner
    final tr = cropRect.topRight;
    final trPath = Path()
      ..moveTo(tr.dx - length, tr.dy)
      ..lineTo(tr.dx + halfStroke, tr.dy)
      ..lineTo(tr.dx + halfStroke, tr.dy + length);
    canvas.drawPath(trPath, paint);

    // Bottom Left Corner
    final bl = cropRect.bottomLeft;
    final blPath = Path()
      ..moveTo(bl.dx + length, bl.dy)
      ..lineTo(bl.dx - halfStroke, bl.dy)
      ..lineTo(bl.dx - halfStroke, bl.dy - length);
    canvas.drawPath(blPath, paint);

    // Bottom Right Corner
    final br = cropRect.bottomRight;
    final brPath = Path()
      ..moveTo(br.dx - length, br.dy)
      ..lineTo(br.dx + halfStroke, br.dy)
      ..lineTo(br.dx + halfStroke, br.dy - length);
    canvas.drawPath(brPath, paint);
  }

  @override
  bool shouldRepaint(_CropHandlesPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.handleColor != handleColor ||
        oldDelegate.handleSizeFactor != handleSizeFactor ||
        oldDelegate.handleThicknessFactor != handleThicknessFactor;
  }
}

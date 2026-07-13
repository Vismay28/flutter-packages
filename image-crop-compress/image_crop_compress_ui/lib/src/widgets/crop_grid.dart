import 'package:flutter/material.dart';

/// A widget that draws the rule-of-thirds grid over the crop area.
class CropGrid extends StatelessWidget {
  const CropGrid({
    super.key,
    required this.cropRect,
    this.gridColor = const Color(0x99FFFFFF),
    this.gridLineWidth = 1.0,
    this.gridLineCount = 2,
    this.opacity = 1.0,
  });

  /// The absolute pixel rectangle representing the active crop area on screen.
  final Rect cropRect;

  /// The color of the grid lines.
  final Color gridColor;

  /// The width of the grid lines.
  final double gridLineWidth;

  /// Number of inner lines per axis (e.g., 2 creates a 3x3 grid).
  final int gridLineCount;

  /// Current opacity of the grid (used for fading in/out during interaction).
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _CropGridPainter(
            cropRect: cropRect,
            gridColor: gridColor,
            gridLineWidth: gridLineWidth,
            gridLineCount: gridLineCount,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CropGridPainter extends CustomPainter {
  _CropGridPainter({
    required this.cropRect,
    required this.gridColor,
    required this.gridLineWidth,
    required this.gridLineCount,
  });
  final Rect cropRect;
  final Color gridColor;
  final double gridLineWidth;
  final int gridLineCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (gridLineCount <= 0) return;

    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = gridLineWidth
      ..style = PaintingStyle.stroke;

    final cellWidth = cropRect.width / (gridLineCount + 1);
    final cellHeight = cropRect.height / (gridLineCount + 1);

    // Draw vertical lines
    for (int i = 1; i <= gridLineCount; i++) {
      final x = cropRect.left + (cellWidth * i);
      canvas.drawLine(
        Offset(x, cropRect.top),
        Offset(x, cropRect.bottom),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i <= gridLineCount; i++) {
      final y = cropRect.top + (cellHeight * i);
      canvas.drawLine(
        Offset(cropRect.left, y),
        Offset(cropRect.right, y),
        paint,
      );
    }

    // Draw outer border
    canvas.drawRect(cropRect, paint);
  }

  @override
  bool shouldRepaint(_CropGridPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.gridLineWidth != gridLineWidth ||
        oldDelegate.gridLineCount != gridLineCount;
  }
}

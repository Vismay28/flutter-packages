import 'package:flutter/material.dart';

/// Theme configuration specifically for the crop area visuals.
class CropTheme {
  /// Creates a [CropTheme].
  const CropTheme({
    this.gridColor = const Color(0x99FFFFFF),
    this.gridLineWidth = 1.0,
    this.gridLineCount = 2,
    this.handleColor = Colors.white,
    this.handleSizeFactor = 0.1,
    this.handleThicknessFactor = 0.015,
    this.overlayColor = const Color(0x99000000),
    this.minimumCropSize = 64.0,
  });

  /// The color of the 3x3 grid lines.
  final Color gridColor;

  /// The width of the grid lines.
  final double gridLineWidth;

  /// Number of inner lines in the grid (default 2 means a 3x3 grid).
  final int gridLineCount;

  /// Color of the corner handles.
  final Color handleColor;

  /// Visual size of the handles relative to the crop area's shortest side (e.g. 0.1 for 10%).
  final double handleSizeFactor;

  /// Stroke width of the corner brackets relative to the crop area's shortest side (e.g. 0.015).
  final double handleThicknessFactor;

  /// The dark overlay mask color outside the crop area.
  final Color overlayColor;

  /// Minimum allowed size (in logical pixels) for the crop area.
  final double minimumCropSize;

  /// Creates a copy of this theme with the given fields replaced.
  CropTheme copyWith({
    Color? gridColor,
    double? gridLineWidth,
    int? gridLineCount,
    Color? handleColor,
    double? handleSizeFactor,
    double? handleThicknessFactor,
    Color? overlayColor,
    double? minimumCropSize,
  }) {
    return CropTheme(
      gridColor: gridColor ?? this.gridColor,
      gridLineWidth: gridLineWidth ?? this.gridLineWidth,
      gridLineCount: gridLineCount ?? this.gridLineCount,
      handleColor: handleColor ?? this.handleColor,
      handleSizeFactor: handleSizeFactor ?? this.handleSizeFactor,
      handleThicknessFactor:
          handleThicknessFactor ?? this.handleThicknessFactor,
      overlayColor: overlayColor ?? this.overlayColor,
      minimumCropSize: minimumCropSize ?? this.minimumCropSize,
    );
  }
}

import 'dart:ui';
import 'package:image_crop_compress_core/src/models/crop_ratio.dart';

/// The intermediate result from the crop UI, passed to the pipeline.
///
/// [CropResult] captures the exact crop parameters selected by the user
/// in the interactive editor. The pipeline uses this data to execute
/// the native crop operation.
class CropResult {

  const CropResult({
    required this.cropRect,
    required this.rotation,
    required this.flippedX,
    required this.flippedY,
    required this.ratio,
  });
  /// The crop rectangle in normalized image coordinates (0.0 - 1.0).
  final Rect cropRect;

  /// Rotation angle in degrees (clockwise).
  final double rotation;

  /// Whether the image is flipped horizontally.
  final bool flippedX;

  /// Whether the image is flipped vertically.
  final bool flippedY;

  /// The aspect ratio constraint used during cropping.
  final CropRatio ratio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropResult &&
          runtimeType == other.runtimeType &&
          cropRect == other.cropRect &&
          rotation == other.rotation &&
          flippedX == other.flippedX &&
          flippedY == other.flippedY &&
          ratio == other.ratio;

  @override
  int get hashCode =>
      cropRect.hashCode ^
      rotation.hashCode ^
      flippedX.hashCode ^
      flippedY.hashCode ^
      ratio.hashCode;

  @override
  String toString() {
    return 'CropResult(cropRect: $cropRect, rotation: $rotation, flippedX: $flippedX, flippedY: $flippedY, ratio: $ratio)';
  }
}

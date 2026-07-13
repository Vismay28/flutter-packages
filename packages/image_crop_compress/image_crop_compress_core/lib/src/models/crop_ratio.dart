/// Defines aspect ratio constraints for crop operations.
///
/// [CropRatio] provides named constants for common ratios and a
/// [custom] factory for arbitrary aspect ratios.
class CropRatio {

  const CropRatio._(this.aspectRatio, this.label);

  /// Creates a custom crop ratio constraint.
  factory CropRatio.custom(double width, double height, {String? label}) {
    assert(width > 0 && height > 0, 'Width and height must be positive.');
    final ratio = width / height;
    final displayLabel = label ?? '${width.toInt()}:${height.toInt()}';
    return CropRatio._(ratio, displayLabel);
  }
  /// The underlying aspect ratio (width / height).
  ///
  /// If `null`, there is no constraint (free cropping).
  final double? aspectRatio;
  
  /// The label for UI display.
  final String label;

  /// No constraint (free cropping).
  static const CropRatio free = CropRatio._(null, 'Free');

  /// 1:1 aspect ratio (square), common for profile pictures.
  static const CropRatio square = CropRatio._(1.0, '1:1');

  /// 9:16 aspect ratio, common for stories and reels.
  static const CropRatio story = CropRatio._(9 / 16, '9:16');

  /// 4:5 aspect ratio, common for portrait social posts.
  static const CropRatio post = CropRatio._(4 / 5, '4:5');

  /// 16:9 aspect ratio, common for landscape video thumbnails.
  static const CropRatio landscape = CropRatio._(16 / 9, '16:9');

  /// 1:1 aspect ratio designed for circular masks.
  static const CropRatio profile = CropRatio._(1.0, 'Profile');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropRatio &&
          runtimeType == other.runtimeType &&
          aspectRatio == other.aspectRatio &&
          label == other.label;

  @override
  int get hashCode => aspectRatio.hashCode ^ label.hashCode;

  @override
  String toString() => 'CropRatio(aspectRatio: $aspectRatio, label: $label)';
}

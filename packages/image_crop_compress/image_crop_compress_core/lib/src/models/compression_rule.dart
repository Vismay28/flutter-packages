/// Defines compression strategies for the compress operation.
///
/// [CompressionRule] encapsulates both quality-based and size-based
/// compression parameters. The native engine uses these rules to
/// determine how aggressively to compress the image.
class CompressionRule {

  const CompressionRule._({this.quality, this.maxSizeKB})
      : assert(
          quality == null || (quality >= 1 && quality <= 100),
          'quality must be between 1 and 100',
        ),
        assert(
          maxSizeKB == null || maxSizeKB > 0,
          'maxSizeKB must be greater than 0',
        ),
        assert(
          quality != null || maxSizeKB != null,
          'Must provide either quality or maxSizeKB',
        );

  /// Creates a quality-based compression rule.
  ///
  /// The native engine will encode the image at the given [quality] (1-100).
  factory CompressionRule.quality(int quality) {
    return CompressionRule._(quality: quality);
  }

  /// Creates a size-based compression rule.
  ///
  /// The native engine will iteratively reduce quality until the resulting
  /// image size is less than or equal to [maxSizeKB].
  factory CompressionRule.maxSize(int maxSizeKB) {
    return CompressionRule._(maxSizeKB: maxSizeKB);
  }

  /// Creates a combined compression rule.
  ///
  /// The native engine will encode the image at [quality], but if the size
  /// exceeds [maxSizeKB], it will further reduce quality to meet the limit.
  factory CompressionRule.qualityAndSize(int quality, int maxSizeKB) {
    return CompressionRule._(quality: quality, maxSizeKB: maxSizeKB);
  }
  /// The target JPEG/WebP/HEIF quality (1-100).
  final int? quality;

  /// The maximum allowed file size in kilobytes (KB).
  final int? maxSizeKB;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompressionRule &&
          runtimeType == other.runtimeType &&
          quality == other.quality &&
          maxSizeKB == other.maxSizeKB;

  @override
  int get hashCode => quality.hashCode ^ maxSizeKB.hashCode;

  @override
  String toString() {
    return 'CompressionRule(quality: $quality, maxSizeKB: $maxSizeKB)';
  }
}

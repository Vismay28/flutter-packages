/// Supported output image formats.
///
/// [ImageFormat] defines the formats that the processing pipeline can
/// convert images to. Each format has associated file extension and
/// MIME type metadata.
enum ImageFormat {
  /// Lossy format, generally smallest size for photographs.
  jpeg,

  /// Lossless format, supports alpha channel (transparency).
  png,

  /// Modern format, excellent compression and supports alpha.
  webp,

  /// High Efficiency Image Format, iOS-native, excellent compression.
  heif;

  /// Returns the standard file extension for this format without a leading dot.
  String get extension {
    switch (this) {
      case ImageFormat.jpeg:
        return 'jpg';
      case ImageFormat.png:
        return 'png';
      case ImageFormat.webp:
        return 'webp';
      case ImageFormat.heif:
        return 'heif';
    }
  }

  /// Returns the standard MIME type string for this format.
  String get mimeType {
    switch (this) {
      case ImageFormat.jpeg:
        return 'image/jpeg';
      case ImageFormat.png:
        return 'image/png';
      case ImageFormat.webp:
        return 'image/webp';
      case ImageFormat.heif:
        return 'image/heif';
    }
  }
}

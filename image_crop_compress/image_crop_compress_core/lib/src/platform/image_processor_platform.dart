import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:image_crop_compress_core/src/platform/image_processor_method_channel.dart';

/// The platform interface for native image processing operations.
///
/// This abstract class defines the contract between the Dart side and
/// platform-specific implementations (Android/iOS). Platform packages
/// (`image_crop_compress_android`, `image_crop_compress_ios`) extend
/// this class to provide native functionality.
///
/// ## Platform Registration
///
/// Platform implementations register themselves by setting [instance]:
///
/// ```dart
/// class ImageCropCompressAndroid extends ImageProcessorPlatform {
///   static void registerWith() {
///     ImageProcessorPlatform.instance = ImageCropCompressAndroid();
///   }
/// }
/// ```
///
/// ## Default Implementation
///
/// The default implementation is [MethodChannelImageProcessor], which
/// communicates with native code via a [MethodChannel].
///
/// See also:
/// - [MethodChannelImageProcessor] for the default MethodChannel implementation
/// - `image_crop_compress_android` for the Android implementation
/// - `image_crop_compress_ios` for the iOS implementation
abstract class ImageProcessorPlatform extends PlatformInterface {
  /// Constructs an [ImageProcessorPlatform].
  ImageProcessorPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImageProcessorPlatform _instance = MethodChannelImageProcessor();

  /// The current platform-specific implementation.
  ///
  /// Defaults to [MethodChannelImageProcessor]. Platform packages
  /// override this during registration.
  static ImageProcessorPlatform get instance => _instance;

  /// Sets the platform-specific implementation.
  ///
  /// Platform packages call this in their `registerWith()` method.
  /// The [instance] must pass [PlatformInterface.verify] to ensure
  /// it extends this class properly.
  static set instance(ImageProcessorPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Returns the platform version string.
  ///
  /// Used during development to verify the platform channel
  /// round-trip is working correctly. Returns a human-readable
  /// string like `"Android 14"` or `"iOS 17.0"`.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Future platform methods (Step 4+)
  // ---------------------------------------------------------------------------

  /// Crops an image at [sourcePath] using the given crop parameters.
  ///
  /// Crop coordinates are expressed as percentages (0.0–1.0) of the
  /// source image dimensions:
  /// - [cropX], [cropY]: Top-left corner of the crop rectangle
  /// - [cropWidth], [cropHeight]: Size of the crop rectangle
  /// - [rotation]: Rotation in degrees (0, 90, 180, 270)
  /// - [flipX], [flipY]: Mirror along X or Y axis
  /// - [outputQuality]: JPEG quality (1–100), only used for JPEG output
  ///
  /// Returns a map containing:
  /// - `path` (`String`): File path of the cropped image
  /// - `width` (`int`): Width in pixels
  /// - `height` (`int`): Height in pixels
  /// - `sizeInBytes` (`int`): File size in bytes
  ///
  /// Throws [UnimplementedError] until Step 4 implementation.
  Future<Map<String, dynamic>> crop({
    required String sourcePath,
    required double cropX,
    required double cropY,
    required double cropWidth,
    required double cropHeight,
    double rotation = 0.0,
    bool flipX = false,
    bool flipY = false,
    int? outputQuality,
  }) {
    throw UnimplementedError('crop() has not been implemented.');
  }

  /// Compresses an image to the target quality or file size.
  ///
  /// - [quality]: JPEG quality (1–100). Lower = smaller file.
  /// - [maxSizeKB]: Target maximum file size in kilobytes. The engine
  ///   will iteratively reduce quality until the target is met.
  ///
  /// At least one of [quality] or [maxSizeKB] must be provided.
  ///
  /// Returns a map with `path`, `width`, `height`, `sizeInBytes`,
  /// and `qualityUsed` (the final quality level selected).
  ///
  /// Throws [UnimplementedError] until Step 5 implementation.
  Future<Map<String, dynamic>> compress({
    required String sourcePath,
    int? quality,
    int? maxSizeKB,
  }) {
    throw UnimplementedError('compress() has not been implemented.');
  }

  /// Resizes an image to the given dimensions.
  ///
  /// If [maintainAspectRatio] is `true` (default), providing only
  /// [width] or [height] will calculate the other proportionally.
  ///
  /// Throws [UnimplementedError] until Step 5 implementation.
  Future<Map<String, dynamic>> resize({
    required String sourcePath,
    int? width,
    int? height,
    bool maintainAspectRatio = true,
  }) {
    throw UnimplementedError('resize() has not been implemented.');
  }

  /// Converts an image to a different format.
  ///
  /// [targetFormat] is the file extension: `"jpg"`, `"png"`, `"webp"`, `"heif"`.
  ///
  /// Throws [UnimplementedError] until Step 5 implementation.
  Future<Map<String, dynamic>> convert({
    required String sourcePath,
    required String targetFormat,
    int? quality,
  }) {
    throw UnimplementedError('convert() has not been implemented.');
  }

  /// Strips EXIF, GPS, and camera metadata from an image.
  ///
  /// Returns a clean image with no embedded metadata.
  ///
  /// Throws [UnimplementedError] until Step 5 implementation.
  Future<Map<String, dynamic>> stripMetadata({
    required String sourcePath,
  }) {
    throw UnimplementedError('stripMetadata() has not been implemented.');
  }
}

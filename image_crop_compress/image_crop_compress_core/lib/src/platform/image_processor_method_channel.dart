import 'package:flutter/services.dart';

import 'package:image_crop_compress_core/src/platform/image_processor_platform.dart';

/// A [MethodChannel]-based implementation of [ImageProcessorPlatform].
///
/// This is the default implementation used when no platform-specific
/// package overrides it. It communicates with native code via a
/// [MethodChannel] named `image_crop_compress`.
///
/// ## Channel Protocol
///
/// All methods invoke named methods on the channel and pass arguments
/// as `Map<String, dynamic>`. Native code responds with the result
/// or throws a [PlatformException] on failure.
///
/// | Dart Method          | Channel Method         | Arguments                    |
/// |:---------------------|:-----------------------|:-----------------------------|
/// | `getPlatformVersion` | `getPlatformVersion`   | none                         |
/// | `crop`               | `crop`                 | sourcePath, cropX, cropY, …  |
/// | `compress`           | `compress`             | sourcePath, quality, …       |
/// | `resize`             | `resize`               | sourcePath, width, height, … |
/// | `convert`            | `convert`              | sourcePath, targetFormat, …  |
/// | `stripMetadata`      | `stripMetadata`        | sourcePath                   |
class MethodChannelImageProcessor extends ImageProcessorPlatform {
  /// The method channel used to communicate with native code.
  ///
  /// Channel name: `image_crop_compress`
  final MethodChannel _channel = const MethodChannel('image_crop_compress');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
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
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('crop', {
      'sourcePath': sourcePath,
      'cropX': cropX,
      'cropY': cropY,
      'cropWidth': cropWidth,
      'cropHeight': cropHeight,
      'rotation': rotation,
      'flipX': flipX,
      'flipY': flipY,
      'outputQuality': ?outputQuality,
    });
    return Map<String, dynamic>.from(result!);
  }

  @override
  Future<Map<String, dynamic>> compress({
    required String sourcePath,
    int? quality,
    int? maxSizeKB,
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'compress',
      {
        'sourcePath': sourcePath,
        'quality': ?quality,
        'maxSizeKB': ?maxSizeKB,
      },
    );
    return Map<String, dynamic>.from(result!);
  }

  @override
  Future<Map<String, dynamic>> resize({
    required String sourcePath,
    int? width,
    int? height,
    bool maintainAspectRatio = true,
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'resize',
      {
        'sourcePath': sourcePath,
        'width': ?width,
        'height': ?height,
        'maintainAspectRatio': maintainAspectRatio,
      },
    );
    return Map<String, dynamic>.from(result!);
  }

  @override
  Future<Map<String, dynamic>> convert({
    required String sourcePath,
    required String targetFormat,
    int? quality,
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'convert',
      {
        'sourcePath': sourcePath,
        'targetFormat': targetFormat,
        'quality': ?quality,
      },
    );
    return Map<String, dynamic>.from(result!);
  }

  @override
  Future<Map<String, dynamic>> stripMetadata({
    required String sourcePath,
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'stripMetadata',
      {'sourcePath': sourcePath},
    );
    return Map<String, dynamic>.from(result!);
  }
}

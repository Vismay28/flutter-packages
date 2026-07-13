/// Android implementation of the image_crop_compress platform interface.
///
/// This package provides native Android image processing using:
/// - `Bitmap` / `Canvas` / `Matrix` for crop, rotate, and flip
/// - `Bitmap.compress()` for compression and format conversion
/// - `ExifInterface` for metadata operations
///
/// ## Registration
///
/// This plugin is automatically registered via the federated plugin
/// system. App developers should never need to interact with this
/// package directly — they depend on `image_crop_compress` which
/// endorses this implementation.
library;

import 'package:flutter/services.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';

/// The Android implementation of [ImageProcessorPlatform].
///
/// Registers itself as the platform implementation when the Android
/// plugin is loaded by Flutter's plugin system.
class ImageCropCompressAndroid extends ImageProcessorPlatform {
  /// The method channel used to communicate with the native Android code.
  final MethodChannel _channel = const MethodChannel('image_crop_compress');

  /// Registers this class as the default [ImageProcessorPlatform] instance.
  ///
  /// Called automatically by the Flutter plugin system. App developers
  /// should not call this directly.
  static void registerWith() {
    ImageProcessorPlatform.instance = ImageCropCompressAndroid();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return _channel.invokeMethod<String>('getPlatformVersion');
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

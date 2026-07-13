import 'dart:io';
import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/operations/base_operation.dart';
import 'package:image_crop_compress_core/src/platform/image_processor_platform.dart';

/// Defines the axis along which an image should be flipped.
enum FlipDirection {
  /// Flip horizontally (left-to-right).
  horizontal,

  /// Flip vertically (top-to-bottom).
  vertical,

  /// Flip both horizontally and vertically.
  both,
}

/// Flip operation — mirrors an image along an axis.
///
/// Supports [FlipDirection.horizontal], [FlipDirection.vertical],
/// and [FlipDirection.both].
class FlipOperation extends BaseOperation {

  const FlipOperation(this.direction);
  final FlipDirection direction;

  @override
  String get operationName => 'Flip';

  @override
  Future<ProcessedImage> execute(ProcessedImage input) async {
    final flipX = direction == FlipDirection.horizontal || direction == FlipDirection.both;
    final flipY = direction == FlipDirection.vertical || direction == FlipDirection.both;

    // We use the crop method with a full image rect to perform standalone flip natively.
    final Map<String, dynamic> response = await ImageProcessorPlatform.instance.crop(
      sourcePath: input.path,
      cropX: 0.0,
      cropY: 0.0,
      cropWidth: 1.0,
      cropHeight: 1.0,
      flipX: flipX,
      flipY: flipY,
    );

    final String outputPath = response['path'] as String;
    final int sizeInBytes = response['sizeInBytes'] as int;
    final int width = response['width'] as int;
    final int height = response['height'] as int;
    final String extension = response['extension'] as String? ?? input.extension;
    final String mimeType = response['mimeType'] as String? ?? input.mimeType;

    final file = File(outputPath);
    final bytes = await file.readAsBytes();

    return input.copyWith(
      file: file,
      bytes: bytes,
      path: outputPath,
      extension: extension,
      mimeType: mimeType,
      width: width,
      height: height,
      sizeInBytes: sizeInBytes,
    );
  }
}

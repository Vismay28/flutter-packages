import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/operations/base_operation.dart';
import 'package:image_crop_compress_core/src/platform/image_processor_platform.dart';
import 'package:image_crop_compress_core/src/models/crop_result.dart';
import 'dart:io';

/// Crop operation — extracts a rectangular region from an image.
///
/// Delegates to native platform engines:
/// - **Android**: `Bitmap.createBitmap()` with `Matrix` for rotation/flip
/// - **iOS**: `CGImage.cropping(to:)` with `CGAffineTransform`
class CropOperation extends BaseOperation {

  const CropOperation(this.result, {this.outputQuality});
  final CropResult result;
  final int? outputQuality;

  @override
  String get operationName => 'Crop';

  @override
  Future<ProcessedImage> execute(ProcessedImage input) async {
    final Map<String, dynamic> response = await ImageProcessorPlatform.instance.crop(
      sourcePath: input.path,
      cropX: result.cropRect.left,
      cropY: result.cropRect.top,
      cropWidth: result.cropRect.width,
      cropHeight: result.cropRect.height,
      rotation: result.rotation,
      flipX: result.flippedX,
      flipY: result.flippedY,
      outputQuality: outputQuality,
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

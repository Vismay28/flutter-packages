import 'dart:io';
import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/operations/base_operation.dart';
import 'package:image_crop_compress_core/src/platform/image_processor_platform.dart';

/// Rotate operation — rotates an image by a given angle.
///
/// Supports 90° increments (0°, 90°, 180°, 270°) for lossless rotation.
/// Arbitrary angles may be supported in future versions.
class RotateOperation extends BaseOperation {

  const RotateOperation(this.degrees);
  final double degrees;

  @override
  String get operationName => 'Rotate';

  @override
  Future<ProcessedImage> execute(ProcessedImage input) async {
    // We use the crop method with a full image rect to perform standalone rotation natively.
    final Map<String, dynamic> response = await ImageProcessorPlatform.instance.crop(
      sourcePath: input.path,
      cropX: 0.0,
      cropY: 0.0,
      cropWidth: 1.0,
      cropHeight: 1.0,
      rotation: degrees,
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

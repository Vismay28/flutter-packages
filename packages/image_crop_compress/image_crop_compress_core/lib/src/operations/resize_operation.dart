import 'dart:io';
import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/operations/base_operation.dart';
import 'package:image_crop_compress_core/src/platform/image_processor_platform.dart';

/// Resize operation — rescales an image.
class ResizeOperation extends BaseOperation {

  const ResizeOperation({
    this.width,
    this.height,
    this.maintainAspectRatio = true,
  }) : assert(width != null || height != null, 'Must provide width or height');
  final int? width;
  final int? height;
  final bool maintainAspectRatio;

  @override
  String get operationName => 'Resize';

  @override
  Future<ProcessedImage> execute(ProcessedImage input) async {
    final Map<String, dynamic> response = await ImageProcessorPlatform.instance.resize(
      sourcePath: input.path,
      width: width,
      height: height,
      maintainAspectRatio: maintainAspectRatio,
    );

    final String outputPath = response['path'] as String;
    final int sizeInBytes = response['sizeInBytes'] as int;
    final int outWidth = response['width'] as int;
    final int outHeight = response['height'] as int;
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
      width: outWidth,
      height: outHeight,
      sizeInBytes: sizeInBytes,
    );
  }
}

import 'dart:io';
import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/operations/base_operation.dart';
import 'package:image_crop_compress_core/src/platform/image_processor_platform.dart';
import 'package:image_crop_compress_core/src/models/image_format.dart';

/// Convert operation — changes the image format (e.g. PNG to JPEG).
class ConvertOperation extends BaseOperation {

  const ConvertOperation(this.targetFormat, {this.quality});
  final ImageFormat targetFormat;
  final int? quality;

  @override
  String get operationName => 'Convert';

  @override
  Future<ProcessedImage> execute(ProcessedImage input) async {
    final Map<String, dynamic> response = await ImageProcessorPlatform.instance.convert(
      sourcePath: input.path,
      targetFormat: targetFormat.extension,
      quality: quality,
    );

    final String outputPath = response['path'] as String;
    final int sizeInBytes = response['sizeInBytes'] as int;
    final int width = response['width'] as int;
    final int height = response['height'] as int;
    final String extension = response['extension'] as String? ?? targetFormat.extension;
    final String mimeType = response['mimeType'] as String? ?? targetFormat.mimeType;

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

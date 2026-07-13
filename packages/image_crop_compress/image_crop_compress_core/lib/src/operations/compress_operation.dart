import 'dart:io';
import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/operations/base_operation.dart';
import 'package:image_crop_compress_core/src/platform/image_processor_platform.dart';
import 'package:image_crop_compress_core/src/models/compression_rule.dart';

/// Compress operation — reduces file size based on quality or size rules.
class CompressOperation extends BaseOperation {

  const CompressOperation(this.rule);
  final CompressionRule rule;

  @override
  String get operationName => 'Compress';

  @override
  Future<ProcessedImage> execute(ProcessedImage input) async {
    final Map<String, dynamic> response = await ImageProcessorPlatform.instance.compress(
      sourcePath: input.path,
      quality: rule.quality,
      maxSizeKB: rule.maxSizeKB,
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

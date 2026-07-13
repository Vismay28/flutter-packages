import 'dart:io';
import 'package:image_crop_compress_core/src/core/pipeline.dart';
import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/models/compression_rule.dart';
import 'package:image_crop_compress_core/src/models/crop_ratio.dart';
import 'package:image_crop_compress_core/src/models/crop_result.dart';
import 'package:image_crop_compress_core/src/models/image_format.dart';
import 'package:image_crop_compress_core/src/operations/compress_operation.dart';
import 'package:image_crop_compress_core/src/operations/convert_operation.dart';
import 'package:image_crop_compress_core/src/operations/crop_operation.dart';
import 'package:image_crop_compress_core/src/operations/flip_operation.dart';
import 'package:image_crop_compress_core/src/operations/metadata_operation.dart';
import 'package:image_crop_compress_core/src/operations/resize_operation.dart';
import 'package:image_crop_compress_core/src/operations/rotate_operation.dart';
import 'dart:ui';

/// The fluent builder entry point for image processing pipelines.
///
/// [ImageProcessor] provides a chainable API for composing image operations.
/// Each method adds an operation to an internal [Pipeline], and terminal
/// methods ([save], [export]) execute the pipeline and return
/// a [ProcessedImage].
class ImageProcessor {

  ImageProcessor(this._sourceFile);
  final File _sourceFile;
  final Pipeline _pipeline = Pipeline();

  /// Adds a crop operation to the pipeline.
  /// Note: The actual coordinates for interactive crop would normally come from UI.
  /// Here we allow passing a pre-defined [CropResult].
  ImageProcessor crop({
    required Rect rect,
    CropRatio ratio = CropRatio.free,
    double rotation = 0.0,
    bool flipX = false,
    bool flipY = false,
    int? outputQuality,
  }) {
    final result = CropResult(
      cropRect: rect,
      rotation: rotation,
      flippedX: flipX,
      flippedY: flipY,
      ratio: ratio,
    );
    _pipeline.addOperation(CropOperation(result, outputQuality: outputQuality));
    return this;
  }

  /// Adds a compress operation to the pipeline.
  ImageProcessor compress({int? quality, int? maxSizeKB}) {
    CompressionRule rule;
    if (quality != null && maxSizeKB != null) {
      rule = CompressionRule.qualityAndSize(quality, maxSizeKB);
    } else if (quality != null) {
      rule = CompressionRule.quality(quality);
    } else if (maxSizeKB != null) {
      rule = CompressionRule.maxSize(maxSizeKB);
    } else {
      throw ArgumentError('Must provide either quality or maxSizeKB');
    }
    _pipeline.addOperation(CompressOperation(rule));
    return this;
  }

  /// Adds a resize operation to the pipeline.
  ImageProcessor resize({int? width, int? height, bool maintainAspectRatio = true}) {
    _pipeline.addOperation(ResizeOperation(
      width: width,
      height: height,
      maintainAspectRatio: maintainAspectRatio,
    ));
    return this;
  }

  /// Adds a rotate operation to the pipeline.
  ImageProcessor rotate({required double degrees}) {
    _pipeline.addOperation(RotateOperation(degrees));
    return this;
  }

  /// Adds a flip operation to the pipeline.
  ImageProcessor flip(FlipDirection direction) {
    _pipeline.addOperation(FlipOperation(direction));
    return this;
  }

  /// Adds a format convert operation to the pipeline.
  ImageProcessor convert(ImageFormat format, {int? quality}) {
    _pipeline.addOperation(ConvertOperation(format, quality: quality));
    return this;
  }

  /// Adds a metadata strip operation to the pipeline.
  ImageProcessor stripMetadata() {
    _pipeline.addOperation(const MetadataOperation());
    return this;
  }

  /// Executes the pipeline and returns the final [ProcessedImage].
  Future<ProcessedImage> save() async {
    // Get initial image metadata (this would ideally come from a platform call,
    // but for now we create a basic ProcessedImage for the source file)
    final initialBytes = await _sourceFile.readAsBytes();
    final extension = _sourceFile.path.split('.').last.toLowerCase();
    
    // Default initial image object
    final inputImage = ProcessedImage(
      file: _sourceFile,
      bytes: initialBytes,
      path: _sourceFile.path,
      extension: extension,
      mimeType: 'image/$extension',
      width: 0, // Should be resolved
      height: 0, // Should be resolved
      sizeInBytes: initialBytes.length,
    );

    return _pipeline.execute(inputImage);
  }
}

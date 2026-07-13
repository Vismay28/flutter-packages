import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:image_crop_compress_core/src/core/pipeline.dart';
import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/models/compression_rule.dart';
import 'package:image_crop_compress_core/src/models/crop_ratio.dart';
import 'package:image_crop_compress_core/src/models/crop_result.dart';
import 'package:image_crop_compress_core/src/models/image_format.dart';
import 'package:image_crop_compress_core/src/operations/compress_operation.dart';
import 'package:image_crop_compress_core/src/operations/convert_operation.dart';
import 'package:image_crop_compress_core/src/operations/crop_operation.dart';

/// State of the [ImageProcessorController].
class ImageProcessorState {

  const ImageProcessorState({
    this.file,
    this.cropRect = const Rect.fromLTWH(0, 0, 1, 1),
    this.rotation = 0.0,
    this.flippedX = false,
    this.flippedY = false,
    this.ratio = CropRatio.free,
  });
  final File? file;
  final Rect cropRect;
  final double rotation;
  final bool flippedX;
  final bool flippedY;
  final CropRatio ratio;

  ImageProcessorState copyWith({
    File? file,
    Rect? cropRect,
    double? rotation,
    bool? flippedX,
    bool? flippedY,
    CropRatio? ratio,
  }) {
    return ImageProcessorState(
      file: file ?? this.file,
      cropRect: cropRect ?? this.cropRect,
      rotation: rotation ?? this.rotation,
      flippedX: flippedX ?? this.flippedX,
      flippedY: flippedY ?? this.flippedY,
      ratio: ratio ?? this.ratio,
    );
  }
}

/// Imperative controller for image processing operations.
///
/// [ImageProcessorController] provides a stateful, command-based API for
/// developers who want to build custom UIs or control the processing
/// pipeline programmatically without the fluent builder syntax.
class ImageProcessorController extends ValueNotifier<ImageProcessorState> {
  ImageProcessorController() : super(const ImageProcessorState());

  /// Opens a file for processing.
  Future<void> open(File file) async {
    value = value.copyWith(file: file);
  }

  /// Rotates the image left by 90 degrees.
  void rotateLeft() {
    value = value.copyWith(rotation: (value.rotation - 90) % 360);
  }

  /// Rotates the image right by 90 degrees.
  void rotateRight() {
    value = value.copyWith(rotation: (value.rotation + 90) % 360);
  }

  /// Flips the image horizontally.
  void flipHorizontal() {
    value = value.copyWith(flippedX: !value.flippedX);
  }

  /// Flips the image vertically.
  void flipVertical() {
    value = value.copyWith(flippedY: !value.flippedY);
  }

  /// Sets the crop aspect ratio.
  void setRatio(CropRatio ratio) {
    value = value.copyWith(ratio: ratio);
  }

  /// Sets the crop rectangle (normalized coordinates).
  void setCropRect(Rect rect) {
    value = value.copyWith(cropRect: rect);
  }

  /// Exports the final processed image applying the current state.
  Future<ProcessedImage> export({
    int? compressQuality,
    int? maxSizeKB,
    ImageFormat? format,
  }) async {
    final file = value.file;
    if (file == null) {
      throw StateError('No file opened for processing.');
    }

    final pipeline = Pipeline();

    // 1. Crop/Rotate/Flip based on state
    final cropResult = CropResult(
      cropRect: value.cropRect,
      rotation: value.rotation,
      flippedX: value.flippedX,
      flippedY: value.flippedY,
      ratio: value.ratio,
    );
    pipeline.addOperation(CropOperation(cropResult));

    // 2. Compress if requested
    if (compressQuality != null || maxSizeKB != null) {
      CompressionRule rule;
      if (compressQuality != null && maxSizeKB != null) {
        rule = CompressionRule.qualityAndSize(compressQuality, maxSizeKB);
      } else if (compressQuality != null) {
        rule = CompressionRule.quality(compressQuality);
      } else {
        rule = CompressionRule.maxSize(maxSizeKB!);
      }
      pipeline.addOperation(CompressOperation(rule));
    }

    // 3. Format conversion if requested
    if (format != null) {
      pipeline.addOperation(ConvertOperation(format));
    }

    final initialBytes = await file.readAsBytes();
    final extension = file.path.split('.').last.toLowerCase();
    
    final inputImage = ProcessedImage(
      file: file,
      bytes: initialBytes,
      path: file.path,
      extension: extension,
      mimeType: 'image/$extension',
      width: 0,
      height: 0,
      sizeInBytes: initialBytes.length,
    );

    return pipeline.execute(inputImage);
  }
}

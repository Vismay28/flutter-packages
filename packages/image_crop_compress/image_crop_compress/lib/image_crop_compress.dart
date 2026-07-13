/// A modern, responsive image editing toolkit for Flutter.
///
/// **image_crop_compress** provides a complete image processing pipeline
/// with native performance and adaptive UI for phones, tablets, foldables,
/// and desktop.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:image_crop_compress/image_crop_compress.dart';
///
/// // Fluent pipeline API
/// final result = await ImageProcessor(file)
///     .crop(ratio: CropRatio.square)
///     .compress(maxSizeKB: 500)
///     .save();
/// ```
///
/// ## What's Included
///
/// This package re-exports everything from:
/// - `image_crop_compress_core` — Models, pipeline, platform interface
/// - `image_crop_compress_ui` — Responsive editor shell, widgets, themes
///
/// Platform implementations are endorsed automatically:
/// - `image_crop_compress_android` — Native Android processing
/// - `image_crop_compress_ios` — Native iOS processing
///
/// {@category Getting Started}
library;

// Core — models, pipeline, platform interface
export 'package:image_crop_compress_core/image_crop_compress_core.dart';

// UI — responsive editor, widgets, themes
export 'package:image_crop_compress_ui/image_crop_compress_ui.dart';

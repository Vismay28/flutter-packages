/// Core library for the image_crop_compress toolkit.
///
/// This package contains the foundational building blocks:
///
/// - **Models** — Data types like [CropRatio], [ImageFormat], [ProcessedImage]
/// - **Pipeline** — The operation queue engine that powers the fluent API
/// - **Operations** — Abstract and concrete operation definitions
/// - **Platform Interface** — Contract for native platform implementations
///
/// This package is pure Dart (no Flutter widgets). For the responsive editor
/// UI, see `image_crop_compress_ui`.
///
/// {@category Core}
library;

// Platform
export 'src/platform/image_processor_platform.dart';
export 'src/platform/image_processor_method_channel.dart';

// Core
export 'src/core/image_processor.dart';
export 'src/core/image_processor_controller.dart';
export 'src/core/pipeline.dart';
export 'src/core/processed_image.dart';

// Models
export 'src/models/crop_ratio.dart';
export 'src/models/image_format.dart';
export 'src/models/crop_result.dart';
export 'src/models/compression_rule.dart';

// Operations
export 'src/operations/base_operation.dart';
export 'src/operations/crop_operation.dart';
export 'src/operations/compress_operation.dart';
export 'src/operations/resize_operation.dart';
export 'src/operations/convert_operation.dart';
export 'src/operations/rotate_operation.dart';
export 'src/operations/flip_operation.dart';
export 'src/operations/metadata_operation.dart';

import 'package:image_crop_compress_core/src/core/processed_image.dart';

/// Abstract base class for all image processing operations.
///
/// Every operation in the pipeline extends [BaseOperation] and implements
/// the [execute] method. The pipeline calls [execute] on each operation
/// sequentially, passing the previous operation's output as input.
abstract class BaseOperation {
  /// Creates a [BaseOperation].
  const BaseOperation();

  /// Human-readable name for logging and error reporting.
  String get operationName;

  /// Executes this operation on [input] and returns the result.
  ///
  /// Implementations should:
  /// - Never modify the input [ProcessedImage] directly
  /// - Return a new [ProcessedImage] with the transformation applied
  /// - Throw an exception on failure
  Future<ProcessedImage> execute(ProcessedImage input);
}

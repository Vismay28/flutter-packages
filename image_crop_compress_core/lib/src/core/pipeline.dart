import 'package:image_crop_compress_core/src/core/processed_image.dart';
import 'package:image_crop_compress_core/src/operations/base_operation.dart';

/// Exception thrown when an image processing operation fails.
class ImageProcessorException implements Exception {

  ImageProcessorException(this.message, {this.operationName});
  final String message;
  final String? operationName;

  @override
  String toString() {
    if (operationName != null) {
      return 'ImageProcessorException (Operation: $operationName): $message';
    }
    return 'ImageProcessorException: $message';
  }
}

/// The pipeline engine that queues and executes image operations sequentially.
///
/// [Pipeline] is the heart of the image processing toolkit. It maintains
/// an ordered list of [BaseOperation] objects and executes them one by one,
/// passing each operation's [ProcessedImage] output as the next operation's
/// input.
class Pipeline {
  final List<BaseOperation> _operations = [];

  /// The list of queued operations.
  List<BaseOperation> get operations => List.unmodifiable(_operations);

  /// Adds a new operation to the end of the pipeline.
  void addOperation(BaseOperation operation) {
    _operations.add(operation);
  }

  /// Clears all queued operations.
  void clear() {
    _operations.clear();
  }

  /// Executes all operations sequentially on the given [inputImage].
  ///
  /// Returns the final [ProcessedImage] after all operations have completed.
  /// Throws [ImageProcessorException] if any operation fails.
  Future<ProcessedImage> execute(ProcessedImage inputImage) async {
    ProcessedImage currentImage = inputImage;

    for (final operation in _operations) {
      try {
        currentImage = await operation.execute(currentImage);
      } catch (e) {
        throw ImageProcessorException(
          'Failed to execute ${operation.operationName}: $e',
          operationName: operation.operationName,
        );
      }
    }

    return currentImage;
  }
}

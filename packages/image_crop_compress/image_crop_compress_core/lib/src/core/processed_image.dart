import 'dart:io';
import 'dart:typed_data';

/// The universal return type for all image processing operations.
///
/// Every operation in the pipeline — crop, compress, resize, convert,
/// metadata strip — returns a [ProcessedImage]. This ensures a consistent
/// API and enables seamless chaining: one operation's output is the next
/// operation's input.
class ProcessedImage {

  const ProcessedImage({
    required this.file,
    required this.bytes,
    required this.path,
    required this.extension,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.sizeInBytes,
  });
  /// The output file.
  final File file;

  /// Raw bytes (useful for in-memory operations).
  final Uint8List bytes;

  /// Absolute file path.
  final String path;

  /// File extension (e.g. "jpg", "png", "webp").
  final String extension;

  /// MIME type (e.g. "image/jpeg", "image/png").
  final String mimeType;

  /// Width in pixels.
  final int width;

  /// Height in pixels.
  final int height;

  /// File size in bytes.
  final int sizeInBytes;

  /// The aspect ratio (width / height).
  double get aspectRatio => height == 0 ? 0 : width / height;

  /// Creates a copy of this [ProcessedImage] but with the given fields replaced with the new values.
  ProcessedImage copyWith({
    File? file,
    Uint8List? bytes,
    String? path,
    String? extension,
    String? mimeType,
    int? width,
    int? height,
    int? sizeInBytes,
  }) {
    return ProcessedImage(
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      path: path ?? this.path,
      extension: extension ?? this.extension,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
    );
  }

  /// Converts this [ProcessedImage] to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'extension': extension,
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'sizeInBytes': sizeInBytes,
      'aspectRatio': aspectRatio,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessedImage &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          extension == other.extension &&
          mimeType == other.mimeType &&
          width == other.width &&
          height == other.height &&
          sizeInBytes == other.sizeInBytes;

  @override
  int get hashCode =>
      path.hashCode ^
      extension.hashCode ^
      mimeType.hashCode ^
      width.hashCode ^
      height.hashCode ^
      sizeInBytes.hashCode;

  @override
  String toString() {
    return 'ProcessedImage(path: $path, size: ${sizeInBytes}B, ${width}x$height)';
  }
}

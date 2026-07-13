import 'package:flutter/widgets.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';

/// State object held by the [ImageEditorController].
class ImageEditorState {
  /// Creates immutable editor state.
  const ImageEditorState({
    this.ratio = CropRatio.free,
    this.rotationDegrees = 0.0,
    this.flipDirection,
    this.cropRect = const Rect.fromLTWH(0, 0, 1, 1),
  });

  /// The active crop ratio constraint.
  final CropRatio ratio;

  /// Current rotation in degrees.
  final double rotationDegrees;

  /// Current flip direction constraint.
  final FlipDirection? flipDirection;

  /// Normalized crop rectangle (0.0 to 1.0) relative to the image dimensions.
  final Rect cropRect;

  /// Returns this state with the supplied fields replaced.
  ImageEditorState copyWith({
    CropRatio? ratio,
    double? rotationDegrees,
    FlipDirection? flipDirection,
    bool clearFlip = false,
    Rect? cropRect,
  }) {
    return ImageEditorState(
      ratio: ratio ?? this.ratio,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      flipDirection: clearFlip ? null : (flipDirection ?? this.flipDirection),
      cropRect: cropRect ?? this.cropRect,
    );
  }
}

/// Controls the state of the Image Editor UI.
class ImageEditorController extends ValueNotifier<ImageEditorState> {
  /// Creates a controller with optional initial editor state.
  ImageEditorController({ImageEditorState? initialState})
    : super(initialState ?? const ImageEditorState());

  // Crop rectangles are stored normalized to the image. Their normalized
  // aspect ratio must therefore account for the displayed image dimensions.
  double _imageAspectRatio = 1;

  /// Updates the displayed image aspect ratio used for locked crop ratios.
  ///
  /// The viewer calls this when the decoded image dimensions, or a quarter
  /// turn, changes. It keeps an active ratio (such as 1:1) visually correct.
  void setImageAspectRatio(double imageAspectRatio) {
    if (imageAspectRatio <= 0 || imageAspectRatio == _imageAspectRatio) return;
    _imageAspectRatio = imageAspectRatio;
    if (value.ratio.aspectRatio != null) {
      value = value.copyWith(
        cropRect: _cropRectForRatio(value.cropRect, value.ratio),
      );
    }
  }

  /// Sets the crop ratio and enforces the new aspect ratio on the current crop rect.
  void setRatio(CropRatio ratio) {
    if (value.ratio == ratio) return;

    value = value.copyWith(
      ratio: ratio,
      cropRect: _cropRectForRatio(value.cropRect, ratio),
    );
  }

  Rect _cropRectForRatio(Rect cropRect, CropRatio ratio) {
    final targetVisualRatio = ratio.aspectRatio;
    if (targetVisualRatio == null) return cropRect;

    // Convert the visible ratio into normalized image coordinates.
    final targetNormalizedRatio = targetVisualRatio / _imageAspectRatio;
    double width = cropRect.width;
    double height = cropRect.height;
    if (width / height > targetNormalizedRatio) {
      width = height * targetNormalizedRatio;
    } else {
      height = width / targetNormalizedRatio;
    }

    final rect = Rect.fromCenter(
      center: cropRect.center,
      width: width,
      height: height,
    );
    final dx = rect.left < 0
        ? -rect.left
        : (rect.right > 1 ? 1 - rect.right : 0.0);
    final dy = rect.top < 0
        ? -rect.top
        : (rect.bottom > 1 ? 1 - rect.bottom : 0.0);
    return rect.shift(Offset(dx, dy));
  }

  /// Rotates the image 90 degrees clockwise.
  void rotateRight() {
    value = value.copyWith(rotationDegrees: (value.rotationDegrees + 90) % 360);
  }

  /// Rotates the image 90 degrees counter-clockwise.
  void rotateLeft() {
    value = value.copyWith(rotationDegrees: (value.rotationDegrees - 90) % 360);
  }

  /// Flips the image horizontally.
  void flipHorizontal() {
    final current = value.flipDirection;
    if (current == null) {
      value = value.copyWith(flipDirection: FlipDirection.horizontal);
    } else if (current == FlipDirection.horizontal) {
      value = value.copyWith(clearFlip: true);
    } else if (current == FlipDirection.vertical) {
      value = value.copyWith(flipDirection: FlipDirection.both);
    } else {
      value = value.copyWith(flipDirection: FlipDirection.vertical);
    }
  }

  /// Flips the image vertically, preserving any horizontal flip.
  void flipVertical() {
    final current = value.flipDirection;
    if (current == null) {
      value = value.copyWith(flipDirection: FlipDirection.vertical);
    } else if (current == FlipDirection.vertical) {
      value = value.copyWith(clearFlip: true);
    } else if (current == FlipDirection.horizontal) {
      value = value.copyWith(flipDirection: FlipDirection.both);
    } else {
      value = value.copyWith(flipDirection: FlipDirection.horizontal);
    }
  }

  /// Updates the normalized crop rectangle.
  void setCropRect(Rect rect) {
    // Clamp and preserve a valid left-to-right, top-to-bottom rectangle.
    final left = rect.left.clamp(0.0, 1.0).toDouble();
    final top = rect.top.clamp(0.0, 1.0).toDouble();
    final right = rect.right.clamp(left, 1.0).toDouble();
    final bottom = rect.bottom.clamp(top, 1.0).toDouble();
    final clamped = Rect.fromLTRB(left, top, right, bottom);
    value = value.copyWith(cropRect: clamped);
  }

  /// Resets all transforms.
  void reset() {
    value = const ImageEditorState();
  }

  /// Converts the current UI state into a `CropResult` to be processed by the core pipeline.
  CropResult toCropResult() {
    return CropResult(
      cropRect: value.cropRect,
      rotation: value.rotationDegrees,
      flippedX:
          value.flipDirection == FlipDirection.horizontal ||
          value.flipDirection == FlipDirection.both,
      flippedY:
          value.flipDirection == FlipDirection.vertical ||
          value.flipDirection == FlipDirection.both,
      ratio: value.ratio,
    );
  }
}

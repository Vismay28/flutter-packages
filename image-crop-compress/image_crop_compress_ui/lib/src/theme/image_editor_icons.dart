import 'package:flutter/material.dart';

/// Defines the icons used throughout the ImageEditor's toolbar.
///
/// You can provide your own [IconData] or completely custom widgets
/// to seamlessly integrate with your app's design system (e.g., CupertinoIcons,
/// LucideIcons, or custom SVGs).
class ImageEditorIcons {
  const ImageEditorIcons({
    this.rotateLeft = Icons.rotate_left_outlined,
    this.rotateRight = Icons.rotate_right_outlined,
    this.flipHorizontal = Icons.flip_outlined,
    this.flipVertical = Icons.flip_outlined, // Often rotated 90 deg in the UI
    this.reset = Icons.restore_outlined,
    this.aspectRatio = Icons.crop_outlined,
  });

  /// Icon used for the rotate-left tool.
  final IconData rotateLeft;

  /// Icon used for the rotate-right tool.
  final IconData rotateRight;

  /// Icon used for the horizontal flip tool.
  final IconData flipHorizontal;

  /// Icon used for the vertical flip tool.
  final IconData flipVertical;

  /// Icon used for the reset tool.
  final IconData reset;

  /// Icon used for the aspect ratio / crop tool.
  final IconData aspectRatio;

  /// Creates a copy of this class with the given fields replaced.
  ImageEditorIcons copyWith({
    IconData? rotateLeft,
    IconData? rotateRight,
    IconData? flipHorizontal,
    IconData? flipVertical,
    IconData? reset,
    IconData? aspectRatio,
  }) {
    return ImageEditorIcons(
      rotateLeft: rotateLeft ?? this.rotateLeft,
      rotateRight: rotateRight ?? this.rotateRight,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      reset: reset ?? this.reset,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}

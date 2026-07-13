import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/toolbar/crop_toolbar_item.dart';

/// Rotates the image 90 degrees counter-clockwise.
class RotateLeftTool extends CropToolbarItem {
  /// Creates a counter-clockwise rotate toolbar action.
  const RotateLeftTool({
    super.key,
    required super.controller,
    required super.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.rotate_left, color: theme.foregroundColor),
      onPressed: controller.rotateLeft,
      tooltip: 'Rotate counter-clockwise',
    );
  }
}

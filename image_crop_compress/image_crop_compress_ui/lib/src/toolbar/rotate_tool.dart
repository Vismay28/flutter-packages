import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/toolbar/crop_toolbar_item.dart';

/// Rotates the image 90 degrees clockwise.
class RotateTool extends CropToolbarItem {
  /// Creates a rotate toolbar action.
  const RotateTool({
    super.key,
    required super.controller,
    required super.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(theme.icons.rotateRight, color: theme.foregroundColor),
      onPressed: controller.rotateRight,
      tooltip: 'Rotate clockwise',
    );
  }
}

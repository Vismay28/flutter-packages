import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/toolbar/crop_toolbar_item.dart';

/// Mirrors the image horizontally.
class FlipTool extends CropToolbarItem {
  /// Creates a flip toolbar action.
  const FlipTool({
    super.key,
    required super.controller,
    required super.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.flip, color: theme.foregroundColor),
      onPressed: controller.flipHorizontal,
      tooltip: 'Flip horizontally',
    );
  }
}

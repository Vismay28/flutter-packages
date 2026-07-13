import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/toolbar/crop_toolbar_item.dart';

/// Restores the default crop rectangle, rotation, and flip state.
class ResetTool extends CropToolbarItem {
  /// Creates a reset toolbar action.
  const ResetTool({super.key, required super.controller, required super.theme});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(theme.icons.reset, color: theme.foregroundColor),
      onPressed: controller.reset,
      tooltip: 'Reset edits',
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/toolbar/crop_toolbar_item.dart';

/// Mirrors the image vertically.
class FlipVerticalTool extends CropToolbarItem {
  /// Creates a vertical-flip toolbar action.
  const FlipVerticalTool({
    super.key,
    required super.controller,
    required super.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Transform.rotate(
        angle: math.pi / 2,
        child: Icon(Icons.flip, color: theme.foregroundColor),
      ),
      onPressed: controller.flipVertical,
      tooltip: 'Flip vertically',
    );
  }
}

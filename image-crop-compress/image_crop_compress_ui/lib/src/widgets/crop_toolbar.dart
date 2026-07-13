import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/editor/image_editor_controller.dart';
import 'package:image_crop_compress_ui/src/theme/toolbar_theme.dart';
import 'package:image_crop_compress_ui/src/toolbar/flip_tool.dart';
import 'package:image_crop_compress_ui/src/toolbar/ratio_tool.dart';
import 'package:image_crop_compress_ui/src/toolbar/reset_tool.dart';
import 'package:image_crop_compress_ui/src/toolbar/rotate_left_tool.dart';
import 'package:image_crop_compress_ui/src/toolbar/rotate_tool.dart';

/// The responsive toolbar containing multiple tools.
class CropToolbar extends StatelessWidget {
  const CropToolbar({
    super.key,
    required this.controller,
    required this.theme,
    this.axis = Axis.horizontal,
    this.buttonSpacing = 16.0,
  });

  final ImageEditorController controller;
  final ToolbarTheme theme;
  final Axis axis;
  final double buttonSpacing;

  @override
  Widget build(BuildContext context) {
    final children = [
      RotateTool(controller: controller, theme: theme),
      SizedBox(
        width: axis == Axis.horizontal ? buttonSpacing : 0,
        height: axis == Axis.vertical ? buttonSpacing : 0,
      ),
      FlipTool(controller: controller, theme: theme),
      SizedBox(
        width: axis == Axis.horizontal ? buttonSpacing : 0,
        height: axis == Axis.vertical ? buttonSpacing : 0,
      ),
      RatioTool(controller: controller, theme: theme),
      SizedBox(
        width: axis == Axis.horizontal ? buttonSpacing : 0,
        height: axis == Axis.vertical ? buttonSpacing : 0,
      ),
      RotateLeftTool(controller: controller, theme: theme),
      SizedBox(
        width: axis == Axis.horizontal ? buttonSpacing : 0,
        height: axis == Axis.vertical ? buttonSpacing : 0,
      ),
      ResetTool(controller: controller, theme: theme),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: axis == Axis.horizontal
          ? Row(mainAxisSize: MainAxisSize.min, children: children)
          : Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

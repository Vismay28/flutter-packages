import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/theme/image_editor_icons.dart';

/// Theme configuration specifically for the toolbar in the ImageEditor.
class ToolbarTheme {
  const ToolbarTheme({
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.foregroundColor = Colors.white,
    this.activeColor = Colors.blue,
    this.height = 80.0,
    this.icons = const ImageEditorIcons(),
  });

  /// The background color of the toolbar.
  final Color backgroundColor;

  /// The color of the icons and text in the toolbar.
  final Color foregroundColor;

  /// The color used to indicate the active/selected tool.
  final Color activeColor;

  /// Height of the toolbar.
  final double height;

  /// The icons used in the toolbar tools.
  final ImageEditorIcons icons;

  ToolbarTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? activeColor,
    double? height,
    ImageEditorIcons? icons,
  }) {
    return ToolbarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      activeColor: activeColor ?? this.activeColor,
      height: height ?? this.height,
      icons: icons ?? this.icons,
    );
  }
}

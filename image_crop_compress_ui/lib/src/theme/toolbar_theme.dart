import 'package:flutter/material.dart';

/// Theme configuration specifically for the toolbar in the ImageEditor.
class ToolbarTheme {
  const ToolbarTheme({
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.foregroundColor = Colors.white,
    this.activeColor = Colors.blue,
    this.height = 80.0,
  });

  /// The background color of the toolbar.
  final Color backgroundColor;

  /// The color of the icons and text in the toolbar.
  final Color foregroundColor;

  /// The color used to indicate the active/selected tool.
  final Color activeColor;

  /// Height of the toolbar.
  final double height;

  ToolbarTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? activeColor,
    double? height,
  }) {
    return ToolbarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      activeColor: activeColor ?? this.activeColor,
      height: height ?? this.height,
    );
  }
}

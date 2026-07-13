import 'package:flutter/material.dart';

import 'package:image_crop_compress_ui/src/theme/crop_theme.dart';
import 'package:image_crop_compress_ui/src/theme/toolbar_theme.dart';
import 'package:image_crop_compress_ui/src/theme/image_editor_icons.dart';

/// The master theme configuration for the ImageEditor.
class ImageEditorTheme {
  /// Creates an [ImageEditorTheme].
  const ImageEditorTheme({
    this.crop = const CropTheme(),
    this.toolbar = const ToolbarTheme(),
    this.scaffoldBackgroundColor = Colors.black,
    this.appBarBackgroundColor = Colors.black,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 16),
    this.cancelButton,
    this.doneButton,
  });

  /// A modern light theme.
  factory ImageEditorTheme.light() {
    return const ImageEditorTheme(
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      appBarBackgroundColor: Color(0xFFF5F5F5),
      textStyle: TextStyle(color: Colors.black87, fontSize: 16),
      toolbar: ToolbarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        activeColor: Colors.blueAccent,
        icons: ImageEditorIcons(),
      ),
      crop: CropTheme(
        overlayColor: Color(0x99FFFFFF), // Slightly transparent white overlay
        gridColor: Color(0xB3000000), // Semi-transparent black grid
        handleColor: Colors.black, // Dark handles for contrast
      ),
    );
  }

  /// A sleek dark theme.
  factory ImageEditorTheme.dark() {
    return const ImageEditorTheme(
      scaffoldBackgroundColor: Colors.black,
      appBarBackgroundColor: Colors.black,
      textStyle: TextStyle(color: Colors.white, fontSize: 16),
      toolbar: ToolbarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        activeColor: Colors.blueAccent,
        icons: ImageEditorIcons(),
      ),
      crop: CropTheme(
        overlayColor: Color(0x99000000), // Standard dark overlay
        gridColor: Color(0xB3FFFFFF), // Semi-transparent white grid
        handleColor: Colors.white,
      ),
    );
  }

  /// Theme specific to the crop viewer (grid, overlay, handles).
  final CropTheme crop;

  /// Theme specific to the bottom toolbar.
  final ToolbarTheme toolbar;

  /// Global background color for the editor scaffold.
  final Color scaffoldBackgroundColor;

  /// Background color for the AppBar.
  final Color appBarBackgroundColor;

  /// Global text style.
  final TextStyle textStyle;

  /// Custom widget for the Cancel button in the AppBar.
  /// If null, a default generic TextButton is provided.
  final Widget? cancelButton;

  /// Custom widget for the Done button in the AppBar.
  /// If null, a default generic TextButton is provided.
  final Widget? doneButton;

  /// Creates a copy of this theme with the given fields replaced.
  ImageEditorTheme copyWith({
    CropTheme? crop,
    ToolbarTheme? toolbar,
    Color? scaffoldBackgroundColor,
    Color? appBarBackgroundColor,
    TextStyle? textStyle,
    Widget? cancelButton,
    Widget? doneButton,
  }) {
    return ImageEditorTheme(
      crop: crop ?? this.crop,
      toolbar: toolbar ?? this.toolbar,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      textStyle: textStyle ?? this.textStyle,
      cancelButton: cancelButton ?? this.cancelButton,
      doneButton: doneButton ?? this.doneButton,
    );
  }
}

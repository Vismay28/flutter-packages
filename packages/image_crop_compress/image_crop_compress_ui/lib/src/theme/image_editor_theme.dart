import 'package:flutter/material.dart';

import 'package:image_crop_compress_ui/src/theme/crop_theme.dart';
import 'package:image_crop_compress_ui/src/theme/toolbar_theme.dart';

/// The master theme configuration for the ImageEditor.
class ImageEditorTheme {
  /// Creates an [ImageEditorTheme].
  const ImageEditorTheme({
    this.crop = const CropTheme(),
    this.toolbar = const ToolbarTheme(),
    this.scaffoldBackgroundColor = Colors.black,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 14),
  });

  /// Theme specific to the crop viewer (grid, overlay, handles).
  final CropTheme crop;

  /// Theme specific to the bottom toolbar.
  final ToolbarTheme toolbar;

  /// Global background color for the editor scaffold.
  final Color scaffoldBackgroundColor;

  /// Global text style.
  final TextStyle textStyle;

  /// Creates a copy of this theme with the given fields replaced.
  ImageEditorTheme copyWith({
    CropTheme? crop,
    ToolbarTheme? toolbar,
    Color? scaffoldBackgroundColor,
    TextStyle? textStyle,
  }) {
    return ImageEditorTheme(
      crop: crop ?? this.crop,
      toolbar: toolbar ?? this.toolbar,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }
}

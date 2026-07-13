import 'package:flutter/material.dart';
import 'package:image_crop_compress_ui/src/editor/image_editor_controller.dart';
import 'package:image_crop_compress_ui/src/theme/toolbar_theme.dart';

/// Base class for composable controls in a [CropToolbar].
///
/// Extend this class to add a custom editor action while retaining access to
/// the active [controller] and the resolved toolbar [theme].
abstract class CropToolbarItem extends StatelessWidget {
  /// Creates a toolbar item.
  const CropToolbarItem({
    super.key,
    required this.controller,
    required this.theme,
  });

  /// The controller for the image currently being edited.
  final ImageEditorController controller;

  /// Colours and sizing used by the enclosing toolbar.
  final ToolbarTheme theme;
}

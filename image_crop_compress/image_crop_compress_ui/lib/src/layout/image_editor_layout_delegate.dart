import 'package:flutter/widgets.dart';
import 'package:image_crop_compress_ui/src/layout/image_editor_layout.dart';

/// Abstract layout delegate that separates layout from editor logic.
abstract class ImageEditorLayoutDelegate {
  const ImageEditorLayoutDelegate();

  /// Padding around the toolbar.
  EdgeInsets toolbarPadding(ImageEditorLayout layout);

  /// Where the toolbar should be positioned.
  Alignment toolbarPosition(ImageEditorLayout layout);

  /// Spacing between toolbar buttons.
  double buttonSpacing(ImageEditorLayout layout);

  /// Safe area insets for the current device.
  EdgeInsets safeAreaPadding(ImageEditorLayout layout);

  /// Whether the toolbar should be horizontal or vertical.
  Axis toolbarAxis(ImageEditorLayout layout);

  /// Padding around the image editing area.
  EdgeInsets editorPadding(ImageEditorLayout layout);
}

/// The default layout delegate that handles responsive layouts for
/// mobile, tablet, desktop, and foldable devices.
class DefaultImageEditorLayoutDelegate extends ImageEditorLayoutDelegate {
  const DefaultImageEditorLayoutDelegate();

  @override
  EdgeInsets toolbarPadding(ImageEditorLayout layout) {
    switch (layout) {
      case ImageEditorLayout.mobile:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);
      case ImageEditorLayout.tablet:
      case ImageEditorLayout.desktop:
      case ImageEditorLayout
          .foldable: // Assuming opened foldable behaves like tablet
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0);
    }
  }

  @override
  Alignment toolbarPosition(ImageEditorLayout layout) {
    switch (layout) {
      case ImageEditorLayout.mobile:
        return Alignment.bottomCenter;
      case ImageEditorLayout.tablet:
      case ImageEditorLayout.desktop:
      case ImageEditorLayout.foldable:
        return Alignment.centerLeft;
    }
  }

  @override
  double buttonSpacing(ImageEditorLayout layout) {
    return 16.0;
  }

  @override
  EdgeInsets safeAreaPadding(ImageEditorLayout layout) {
    return EdgeInsets.zero; // Handled by standard SafeAreas usually
  }

  @override
  Axis toolbarAxis(ImageEditorLayout layout) {
    switch (layout) {
      case ImageEditorLayout.mobile:
        return Axis.horizontal;
      case ImageEditorLayout.tablet:
      case ImageEditorLayout.desktop:
      case ImageEditorLayout.foldable:
        return Axis.vertical;
    }
  }

  @override
  EdgeInsets editorPadding(ImageEditorLayout layout) {
    switch (layout) {
      case ImageEditorLayout.mobile:
        return const EdgeInsets.only(
          bottom: 100,
        ); // Leave space for bottom toolbar
      case ImageEditorLayout.tablet:
      case ImageEditorLayout.desktop:
      case ImageEditorLayout.foldable:
        return const EdgeInsets.only(left: 100); // Leave space for side toolbar
    }
  }
}

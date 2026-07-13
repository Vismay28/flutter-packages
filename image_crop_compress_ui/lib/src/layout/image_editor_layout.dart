/// Device layout classification and resolution for responsive UI.
///
/// [ImageEditorLayout] classifies the current device into a layout
/// category based on screen dimensions and device characteristics.
/// The [resolve] method determines the appropriate layout from a
/// [BuildContext].
///
/// ## Layout Categories
///
/// ```dart
/// enum ImageEditorLayout {
///   mobile,    // Phones — bottom toolbar
///   tablet,    // Tablets — side toolbar
///   desktop,   // Desktop — dock toolbar
///   foldable,  // Foldables (open) — adaptive panels
/// }
/// ```
///
/// ## Resolution Logic
///
/// ```dart
/// ImageEditorLayout.resolve(context)
/// ```
///
/// | Device                  | Layout      | Toolbar Position |
/// |:------------------------|:------------|:-----------------|
/// | Small/Large Android     | `mobile`    | Bottom bar       |
/// | iPhone                  | `mobile`    | Bottom bar       |
/// | iPad Portrait           | `tablet`    | Floating toolbar |
/// | iPad Landscape          | `tablet`    | Left sidebar     |
/// | Android Tablet          | `tablet`    | Left sidebar     |
/// | Foldable (folded)       | `mobile`    | Bottom bar       |
/// | Foldable (open/dual)    | `foldable`  | Adaptive panels  |
/// | Desktop                 | `desktop`   | Dock             |
///
/// ## Breakpoints
///
/// Instead of `if (tablet)`, use:
///
/// ```dart
/// final layout = ImageEditorLayout.resolve(context);
/// switch (layout) {
///   case ImageEditorLayout.mobile: ...
///   case ImageEditorLayout.tablet: ...
///   case ImageEditorLayout.desktop: ...
///   case ImageEditorLayout.foldable: ...
/// }
/// ```
///
/// ## Responsive Animations
///
/// | Layout    | Transition Style |
/// |:----------|:-----------------|
/// | Mobile    | Bottom sheet     |
/// | Tablet    | Sidebar slide    |
/// | Desktop   | Fade             |
/// | Foldable  | Adaptive         |
library;

import 'package:flutter/widgets.dart';

/// Defines the responsive layout classifications for the Image Editor.
enum ImageEditorLayout {
  mobile,
  tablet,
  desktop,
  foldable;

  /// Resolves the layout based on the current screen constraints and device metrics.
  static ImageEditorLayout resolve(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final shortestSide = size.shortestSide;

    // Detect Foldables (typically roughly square when opened)
    // Note: A true foldable detection would use MediaQuery.displayFeatures,
    // but for simplicity we assume aspect ratio ~1.0 and a certain size.
    final isFoldable =
        size.width > 500 && size.aspectRatio > 0.8 && size.aspectRatio < 1.2;

    if (isFoldable) {
      return ImageEditorLayout.foldable;
    }

    if (shortestSide < 600) {
      return ImageEditorLayout.mobile;
    } else if (shortestSide >= 600 && size.width < 1024) {
      return ImageEditorLayout.tablet;
    } else {
      return ImageEditorLayout.desktop;
    }
  }
}

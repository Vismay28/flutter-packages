/// Responsive image editor UI for the image_crop_compress toolkit.
///
/// This package provides a complete, responsive image editor shell
/// that adapts to phones, tablets, foldables, and desktop devices.
///
/// ## Key Components
///
/// - **Editor** — [ImageEditor] is the responsive editor shell widget
/// - **Layout** — [ImageEditorLayout] resolves device class from context
/// - **Widgets** — Crop viewer, grid, handles, overlay
/// - **Toolbar** — Composable toolbar with built-in and custom tools
/// - **Theme** — Per-device-class theming system
///
/// ## Architecture
///
/// ```
/// ImageEditor
///     ↓
/// ImageEditorLayoutDelegate
///     ↓
/// Widgets (toolbar, handles, grid, overlay)
/// ```
///
/// The editor delegates all layout decisions to [ImageEditorLayoutDelegate],
/// which determines toolbar position, button spacing, padding, and
/// breakpoints based on the resolved [ImageEditorLayout].
///
/// {@category UI}
library;

// Editor
export 'src/editor/image_editor.dart';
export 'src/editor/image_editor_controller.dart';

// Layout delegates
export 'src/layout/image_editor_layout.dart';
export 'src/layout/image_editor_layout_delegate.dart';

// Widgets
export 'src/widgets/crop_viewer.dart';
export 'src/widgets/crop_grid.dart';
export 'src/widgets/crop_handles.dart';
export 'src/widgets/crop_overlay.dart';
export 'src/widgets/crop_toolbar.dart'; // contains the tools as well

// Toolbar building blocks
export 'src/toolbar/crop_toolbar_item.dart';
export 'src/toolbar/rotate_tool.dart';
export 'src/toolbar/rotate_left_tool.dart';
export 'src/toolbar/flip_tool.dart';
export 'src/toolbar/flip_vertical_tool.dart';
export 'src/toolbar/ratio_tool.dart';
export 'src/toolbar/reset_tool.dart';

// Theme
export 'src/theme/image_editor_theme.dart';
export 'src/theme/crop_theme.dart';
export 'src/theme/toolbar_theme.dart';

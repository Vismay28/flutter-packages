import 'package:flutter/material.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';
import 'package:image_crop_compress_ui/src/editor/image_editor_controller.dart';
import 'package:image_crop_compress_ui/src/toolbar/crop_toolbar_item.dart';

/// Opens a picker for the supported crop aspect ratios.
class RatioTool extends CropToolbarItem {
  /// Creates a ratio toolbar action.
  const RatioTool({
    super.key,
    required super.controller,
    required super.theme,
    this.ratios = const [
      CropRatio.free,
      CropRatio.square,
      CropRatio.story,
      CropRatio.post,
      CropRatio.landscape,
    ],
  });

  /// Ratios shown in the picker.
  final List<CropRatio> ratios;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(theme.icons.aspectRatio, color: theme.foregroundColor),
      tooltip: 'Aspect ratio',
      onPressed: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.backgroundColor,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ValueListenableBuilder<ImageEditorState>(
              valueListenable: controller,
              builder: (context, state, child) => Row(
                children: [
                  for (final ratio in ratios)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ChoiceChip(
                        label: Text(ratio.label),
                        selected: state.ratio == ratio,
                        selectedColor: theme.activeColor,
                        labelStyle: TextStyle(
                          color: state.ratio == ratio
                              ? theme.backgroundColor
                              : theme.foregroundColor,
                        ),
                        side: BorderSide(color: theme.activeColor),
                        onSelected: (_) {
                          controller.setRatio(ratio);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

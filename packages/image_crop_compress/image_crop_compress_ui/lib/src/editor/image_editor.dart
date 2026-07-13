import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';
import 'package:image_crop_compress_ui/src/editor/image_editor_controller.dart';
import 'package:image_crop_compress_ui/src/layout/image_editor_layout.dart';
import 'package:image_crop_compress_ui/src/layout/image_editor_layout_delegate.dart';
import 'package:image_crop_compress_ui/src/theme/image_editor_theme.dart';
import 'package:image_crop_compress_ui/src/widgets/crop_toolbar.dart';
import 'package:image_crop_compress_ui/src/widgets/crop_viewer.dart';

/// The responsive image editor shell widget.
class ImageEditor extends StatefulWidget {
  const ImageEditor({
    super.key,
    required this.image,
    required this.onComplete,
    required this.onCancel,
    this.theme = const ImageEditorTheme(),
    this.layoutDelegate = const DefaultImageEditorLayoutDelegate(),
    this.enableCompression = false,
    this.maxSizeKB = 512,
    this.compressionQuality,
  })  : assert(maxSizeKB > 0),
        assert(
          compressionQuality == null ||
              (compressionQuality >= 1 && compressionQuality <= 100),
        );

  final File image;
  final ImageEditorTheme theme;
  final ValueChanged<ProcessedImage> onComplete;
  final VoidCallback onCancel;
  final ImageEditorLayoutDelegate layoutDelegate;

  /// Whether to apply a maximum output-file size during export.
  ///
  /// This is disabled by default, so editing never silently compresses an
  /// image. When enabled, the encoder reduces quality only as needed to meet
  /// [maxSizeKB].
  final bool enableCompression;

  /// Maximum export size when [enableCompression] is true. Defaults to 512 KB.
  final int maxSizeKB;

  /// Optional JPEG/WebP output quality from 1 to 100.
  ///
  /// Without [enableCompression], this is the requested export quality. With
  /// it enabled, this is the initial quality before the size limit is applied.
  final int? compressionQuality;

  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  late ImageEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImageEditorController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processImage() async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()));

      final result = _controller.toCropResult();
      final processor = ImageProcessor(widget.image);

      processor.crop(
        rect: result.cropRect,
        ratio: result.ratio,
        rotation: result.rotation,
        flipX: result.flippedX,
        flipY: result.flippedY,
        outputQuality:
            widget.enableCompression ? null : widget.compressionQuality,
      );

      if (widget.enableCompression) {
        processor.compress(
          quality: widget.compressionQuality,
          maxSizeKB: widget.maxSizeKB,
        );
      }

      final finalImage = await processor.save();
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      widget.onComplete(finalImage);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = ImageEditorLayout.resolve(context);

    final toolbarPadding = widget.layoutDelegate.toolbarPadding(layout);
    final toolbarAlignment = widget.layoutDelegate.toolbarPosition(layout);
    final toolbarAxis = widget.layoutDelegate.toolbarAxis(layout);
    final editorPadding = widget.layoutDelegate.editorPadding(layout);

    return Scaffold(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: widget.theme.scaffoldBackgroundColor,
        foregroundColor: widget.theme.textStyle.color,
        elevation: 0,
        leading: TextButton(
          onPressed: widget.onCancel,
          child: Text('Cancel', style: widget.theme.textStyle),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: _processImage,
            child: Text('Done',
                style: widget.theme.textStyle
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Editor Area
          AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            padding: editorPadding,
            child: CropViewer(
              image: widget.image,
              controller: _controller,
              theme: widget.theme.crop,
            ),
          ),

          // Toolbar Area
          Align(
            alignment: toolbarAlignment,
            child: Padding(
              padding: toolbarPadding,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                // Use the axis in the key to force a rebuild/animation on layout change
                child: CropToolbar(
                  key: ValueKey(toolbarAxis),
                  controller: _controller,
                  theme: widget.theme.toolbar,
                  axis: toolbarAxis,
                  buttonSpacing: widget.layoutDelegate.buttonSpacing(layout),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';

import 'package:image_crop_compress_ui/src/editor/image_editor_controller.dart';
import 'package:image_crop_compress_ui/src/theme/crop_theme.dart';
import 'package:image_crop_compress_ui/src/widgets/crop_grid.dart';
import 'package:image_crop_compress_ui/src/widgets/crop_handles.dart';
import 'package:image_crop_compress_ui/src/widgets/crop_overlay.dart';

enum _DragHandle {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center, // Used for panning the crop box
}

/// The main interactive viewer that handles pan, zoom, and crop gestures.
class CropViewer extends StatefulWidget {
  /// Creates a [CropViewer].
  const CropViewer({
    super.key,
    required this.image,
    required this.controller,
    required this.theme,
  });

  /// The image file being edited.
  final File image;

  /// The controller managing the crop state.
  final ImageEditorController controller;

  /// The theme configuration.
  final CropTheme theme;

  @override
  State<CropViewer> createState() => _CropViewerState();
}

class _CropViewerState extends State<CropViewer> with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late Animation<double> _gridOpacity;

  late AnimationController _viewportAnimationController;
  late Animation<Matrix4> _viewportAnimation;

  Matrix4 _viewportTransform = Matrix4.identity();
  Timer? _debounceTimer;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  Size? _sourceImageSize;
  double _lastRotationDegrees = 0;
  Rect _lastCropRect = const Rect.fromLTWH(0, 0, 1, 1);

  _DragHandle _activeHandle = _DragHandle.none;
  Rect? _startCropRect; // In view coordinates
  Offset? _startTouchPosition; // In view coordinates
  Matrix4? _startViewportTransform;

  @override
  void initState() {
    super.initState();
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _gridOpacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(_gridAnimationController);

    _viewportAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _viewportAnimationController.addListener(() {
      setState(() {
        _viewportTransform = _viewportAnimation.value;
      });
    });

    _lastRotationDegrees = widget.controller.value.rotationDegrees;
    _lastCropRect = widget.controller.value.cropRect;
    widget.controller.addListener(_onEditorStateChanged);
    _resolveImageSize();

    // Automatically zoom to fit the image on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAutoZoom(immediate: true);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onEditorStateChanged);
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    _gridAnimationController.dispose();
    _viewportAnimationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _resolveImageSize() {
    final stream = FileImage(widget.image).resolve(ImageConfiguration.empty);
    _imageStream = stream;
    _imageListener = ImageStreamListener((imageInfo, _) {
      final size = Size(
        imageInfo.image.width.toDouble(),
        imageInfo.image.height.toDouble(),
      );
      if (mounted && size != _sourceImageSize) {
        setState(() => _sourceImageSize = size);
        _syncImageAspectRatio();
        _triggerAutoZoom(immediate: true);
      }
    });
    stream.addListener(_imageListener!);
  }

  void _onEditorStateChanged() {
    final state = widget.controller.value;
    final rotation = state.rotationDegrees;
    final wasCropped = _lastCropRect != const Rect.fromLTWH(0, 0, 1, 1);
    final wasReset =
        wasCropped && state.cropRect == const Rect.fromLTWH(0, 0, 1, 1);
    _lastCropRect = state.cropRect;
    if (rotation == _lastRotationDegrees && !wasReset) return;

    _lastRotationDegrees = rotation;
    _syncImageAspectRatio();
    // A quarter turn changes the image bounds; reset must also discard any
    // user pan/zoom. Re-centre after layout in both cases.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _triggerAutoZoom(immediate: false);
    });
  }

  void _syncImageAspectRatio() {
    final source = _sourceImageSize;
    if (source == null || source.isEmpty) return;
    final isQuarterTurn =
        (widget.controller.value.rotationDegrees ~/ 90) % 2 != 0;
    widget.controller.setImageAspectRatio(
      isQuarterTurn
          ? source.height / source.width
          : source.width / source.height,
    );
  }

  Rect _imageRectFor(Size viewportSize) {
    if (viewportSize.isEmpty) return Rect.zero;

    final source = _sourceImageSize ?? const Size(1, 1);
    final isQuarterTurn =
        (widget.controller.value.rotationDegrees ~/ 90) % 2 != 0;
    final aspectRatio = isQuarterTurn
        ? source.height / source.width
        : source.width / source.height;

    double width = viewportSize.width;
    double height = width / aspectRatio;
    if (height > viewportSize.height) {
      height = viewportSize.height;
      width = height * aspectRatio;
    }

    return Rect.fromCenter(
      center: viewportSize.center(Offset.zero),
      width: width,
      height: height,
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _debounceTimer?.cancel();
    _viewportAnimationController.stop();

    final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final localTouch = stackBox.globalToLocal(details.focalPoint);
    // Apply inverse transform to get coordinate relative to the unscaled/unpanned image box
    final touchInImageSpace = MatrixUtils.transformPoint(
      Matrix4.tryInvert(_viewportTransform) ?? Matrix4.identity(),
      localTouch,
    );

    final viewRect = _imageRectFor(stackBox.size);
    final currentCropRect = widget.controller.value.cropRect;

    // Map normalized crop rect (0..1) to view coordinates
    final absoluteCropRect = Rect.fromLTRB(
      viewRect.left + currentCropRect.left * viewRect.width,
      viewRect.top + currentCropRect.top * viewRect.height,
      viewRect.left + currentCropRect.right * viewRect.width,
      viewRect.top + currentCropRect.bottom * viewRect.height,
    );

    _startCropRect = absoluteCropRect;
    _startTouchPosition = touchInImageSpace;
    _startViewportTransform = _viewportTransform.clone();

    final currentScale = _viewportTransform.getMaxScaleOnAxis();
    _activeHandle =
        _getHitHandle(touchInImageSpace, absoluteCropRect, currentScale);

    _gridAnimationController.forward();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_startCropRect == null || _startTouchPosition == null) return;

    final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final viewRect = _imageRectFor(stackBox.size);

    if (_activeHandle == _DragHandle.none) {
      // PANNING & ZOOMING THE VIEWPORT
      final Matrix4 updatedTransform = _startViewportTransform!.clone();

      // Translate
      updatedTransform.translate(
          details.focalPointDelta.dx, details.focalPointDelta.dy);

      // Scale around the focal point
      final focalPoint = stackBox.globalToLocal(details.focalPoint);
      final scaleDelta = details.scale;

      // To scale around a specific point, we translate to it, scale, then translate back
      updatedTransform.translate(focalPoint.dx, focalPoint.dy);
      updatedTransform.scale(scaleDelta, scaleDelta);
      updatedTransform.translate(-focalPoint.dx, -focalPoint.dy);

      setState(() {
        _viewportTransform = updatedTransform;
      });
      return;
    }

    // DRAGGING A CROP HANDLE OR PANNING THE CROP RECT

    final Matrix4 inverseTransform =
        Matrix4.tryInvert(_viewportTransform) ?? Matrix4.identity();
    final localTouch = stackBox.globalToLocal(details.focalPoint);
    final touchInImageSpace =
        MatrixUtils.transformPoint(inverseTransform, localTouch);
    final delta = touchInImageSpace - _startTouchPosition!;

    Rect newRect = _startCropRect!;

    if (_activeHandle == _DragHandle.center) {
      newRect = _startCropRect!.shift(delta);
    } else {
      // Corner resizing
      if (_activeHandle == _DragHandle.topLeft) {
        newRect = Rect.fromLTRB(
          _startCropRect!.left + delta.dx,
          _startCropRect!.top + delta.dy,
          _startCropRect!.right,
          _startCropRect!.bottom,
        );
      } else if (_activeHandle == _DragHandle.topRight) {
        newRect = Rect.fromLTRB(
          _startCropRect!.left,
          _startCropRect!.top + delta.dy,
          _startCropRect!.right + delta.dx,
          _startCropRect!.bottom,
        );
      } else if (_activeHandle == _DragHandle.bottomLeft) {
        newRect = Rect.fromLTRB(
          _startCropRect!.left + delta.dx,
          _startCropRect!.top,
          _startCropRect!.right,
          _startCropRect!.bottom + delta.dy,
        );
      } else if (_activeHandle == _DragHandle.bottomRight) {
        newRect = Rect.fromLTRB(
          _startCropRect!.left,
          _startCropRect!.top,
          _startCropRect!.right + delta.dx,
          _startCropRect!.bottom + delta.dy,
        );
      }

      // Enforce aspect ratio if locked
      final ratio = widget.controller.value.ratio.aspectRatio;
      if (ratio != null) {
        double w = newRect.width;
        double h = newRect.height;
        if (w / h > ratio) {
          w = h * ratio;
        } else {
          h = w / ratio;
        }

        if (_activeHandle == _DragHandle.topLeft) {
          newRect = Rect.fromLTRB(
              _startCropRect!.right - w,
              _startCropRect!.bottom - h,
              _startCropRect!.right,
              _startCropRect!.bottom);
        } else if (_activeHandle == _DragHandle.topRight) {
          newRect = Rect.fromLTRB(
              _startCropRect!.left,
              _startCropRect!.bottom - h,
              _startCropRect!.left + w,
              _startCropRect!.bottom);
        } else if (_activeHandle == _DragHandle.bottomLeft) {
          newRect = Rect.fromLTRB(
              _startCropRect!.right - w,
              _startCropRect!.top,
              _startCropRect!.right,
              _startCropRect!.top + h);
        } else if (_activeHandle == _DragHandle.bottomRight) {
          newRect = Rect.fromLTRB(_startCropRect!.left, _startCropRect!.top,
              _startCropRect!.left + w, _startCropRect!.top + h);
        }

        newRect = _constrainLockedCornerToImage(
          newRect,
          viewRect,
          _activeHandle,
          ratio,
        );
      }
    }

    // Minimum visual size based on actual scaled pixels
    final scale = _viewportTransform.getMaxScaleOnAxis();
    final minSize = widget.theme.minimumCropSize / scale;
    if (newRect.width < minSize || newRect.height < minSize) return;

    // Normalize back to 0..1
    final normalizedRect = Rect.fromLTRB(
      (newRect.left - viewRect.left) / viewRect.width,
      (newRect.top - viewRect.top) / viewRect.height,
      (newRect.right - viewRect.left) / viewRect.width,
      (newRect.bottom - viewRect.top) / viewRect.height,
    );

    widget.controller.setCropRect(normalizedRect);
  }

  Rect _constrainLockedCornerToImage(
    Rect rect,
    Rect imageRect,
    _DragHandle handle,
    double aspectRatio,
  ) {
    double width = rect.width;
    double height = rect.height;

    double maxWidth;
    double maxHeight;
    switch (handle) {
      case _DragHandle.topLeft:
        maxWidth = rect.right - imageRect.left;
        maxHeight = rect.bottom - imageRect.top;
        break;
      case _DragHandle.topRight:
        maxWidth = imageRect.right - rect.left;
        maxHeight = rect.bottom - imageRect.top;
        break;
      case _DragHandle.bottomLeft:
        maxWidth = rect.right - imageRect.left;
        maxHeight = imageRect.bottom - rect.top;
        break;
      case _DragHandle.bottomRight:
        maxWidth = imageRect.right - rect.left;
        maxHeight = imageRect.bottom - rect.top;
        break;
      case _DragHandle.none:
      case _DragHandle.center:
        return rect;
    }

    // Scale both axes together when a dragged corner reaches an image edge.
    // This prevents normalized-coordinate clamping from turning 1:1 into a
    // rectangle at the boundary.
    final scale = math.min(1.0, math.min(maxWidth / width, maxHeight / height));
    width *= scale;
    height = width / aspectRatio;

    switch (handle) {
      case _DragHandle.topLeft:
        return Rect.fromLTWH(
            rect.right - width, rect.bottom - height, width, height);
      case _DragHandle.topRight:
        return Rect.fromLTWH(rect.left, rect.bottom - height, width, height);
      case _DragHandle.bottomLeft:
        return Rect.fromLTWH(rect.right - width, rect.top, width, height);
      case _DragHandle.bottomRight:
        return Rect.fromLTWH(rect.left, rect.top, width, height);
      case _DragHandle.none:
      case _DragHandle.center:
        return rect;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_activeHandle != _DragHandle.none) {
      _triggerAutoZoom(immediate: false);
    }
    _activeHandle = _DragHandle.none;
    _startCropRect = null;
    _startTouchPosition = null;
    _startViewportTransform = null;
    _gridAnimationController.reverse();
  }

  void _triggerAutoZoom({required bool immediate}) {
    _debounceTimer?.cancel();
    final delay = immediate ? Duration.zero : const Duration(milliseconds: 400);

    _debounceTimer = Timer(delay, () {
      if (!mounted) return;

      final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
      if (stackBox == null || !stackBox.hasSize) return;

      final viewportSize = stackBox.size;
      final imageRect = _imageRectFor(viewportSize);
      final cropRectNormalized = widget.controller.value.cropRect;

      final cropWidthInImage = cropRectNormalized.width * imageRect.width;
      final cropHeightInImage = cropRectNormalized.height * imageRect.height;
      final cropCenterInImage = Offset(
        imageRect.left +
            (cropRectNormalized.left + cropRectNormalized.width / 2) *
                imageRect.width,
        imageRect.top +
            (cropRectNormalized.top + cropRectNormalized.height / 2) *
                imageRect.height,
      );

      // Determine required scale to fit the crop rectangle into the viewport with 10% padding
      const padding = 48.0;
      final targetWidth = viewportSize.width - padding * 2;
      final targetHeight = viewportSize.height - padding * 2;

      final scaleX = targetWidth / cropWidthInImage;
      final scaleY = targetHeight / cropHeightInImage;
      final targetScale = math.min(scaleX, scaleY);

      // Compute the matrix that achieves this scale and centers the cropRect
      final idealMatrix = Matrix4.identity();

      // 1. Move to center of screen
      idealMatrix.translate(viewportSize.width / 2, viewportSize.height / 2);

      // 2. Apply scale
      idealMatrix.scale(targetScale, targetScale);

      // 3. Offset by the center of the crop rectangle (in image coordinates) so it ends up at the origin
      idealMatrix.translate(-cropCenterInImage.dx, -cropCenterInImage.dy);

      if (immediate) {
        setState(() {
          _viewportTransform = idealMatrix;
        });
      } else {
        _viewportAnimation = Matrix4Tween(
          begin: _viewportTransform,
          end: idealMatrix,
        ).animate(CurvedAnimation(
          parent: _viewportAnimationController,
          curve: Curves.easeOutCubic,
        ));
        _viewportAnimationController.forward(from: 0);
      }
    });
  }

  _DragHandle _getHitHandle(Offset touch, Rect bounds, double currentScale) {
    // Touch target shouldn't be affected by zoom - we want a constant physical touch target
    final hitRadius =
        32.0 / currentScale; // 32 logical pixels radius touch target

    if ((touch - bounds.topLeft).distance <= hitRadius) {
      return _DragHandle.topLeft;
    }
    if ((touch - bounds.topRight).distance <= hitRadius) {
      return _DragHandle.topRight;
    }
    if ((touch - bounds.bottomLeft).distance <= hitRadius) {
      return _DragHandle.bottomLeft;
    }
    if ((touch - bounds.bottomRight).distance <= hitRadius) {
      return _DragHandle.bottomRight;
    }

    // If inside crop bounds but not on a handle, allow panning the crop box
    if (bounds.contains(touch)) return _DragHandle.center;

    return _DragHandle.none;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ImageEditorState>(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        return GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageRect = _imageRectFor(constraints.biggest);
              final cropRect = Rect.fromLTRB(
                imageRect.left + state.cropRect.left * imageRect.width,
                imageRect.top + state.cropRect.top * imageRect.height,
                imageRect.left + state.cropRect.right * imageRect.width,
                imageRect.top + state.cropRect.bottom * imageRect.height,
              );

              // Keep every visual layer in the same coordinate system. This is
              // essential when the image bounds swap on a 90° rotation.
              return Transform(
                transform: _viewportTransform,
                alignment: Alignment.topLeft,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fromRect(
                      rect: imageRect,
                      child: RotatedBox(
                        quarterTurns: (state.rotationDegrees ~/ 90) % 4,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(
                              state.flipDirection == FlipDirection.horizontal ||
                                      state.flipDirection == FlipDirection.both
                                  ? -1.0
                                  : 1.0,
                              state.flipDirection == FlipDirection.vertical ||
                                      state.flipDirection == FlipDirection.both
                                  ? -1.0
                                  : 1.0,
                            ),
                          child: Image.file(
                            widget.image,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _gridAnimationController,
                        builder: (context, child) => Stack(
                          fit: StackFit.expand,
                          children: [
                            CropOverlay(
                                cropRect: cropRect,
                                overlayColor: widget.theme.overlayColor),
                            CropGrid(
                              cropRect: cropRect,
                              gridColor: widget.theme.gridColor,
                              gridLineWidth: widget.theme.gridLineWidth,
                              gridLineCount: widget.theme.gridLineCount,
                              opacity: _gridOpacity.value,
                            ),
                            CropHandles(
                              cropRect: cropRect,
                              handleColor: widget.theme.handleColor,
                              handleSizeFactor: widget.theme.handleSizeFactor,
                              handleThicknessFactor:
                                  widget.theme.handleThicknessFactor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';
import 'package:image_crop_compress_ui/image_crop_compress_ui.dart';

void main() {
  group('ImageEditorController ratios', () {
    test('square ratio is visually square for a portrait image', () {
      final controller = ImageEditorController();

      controller.setImageAspectRatio(0.5);
      controller.setRatio(CropRatio.square);

      final crop = controller.value.cropRect;
      expect(crop.width / crop.height, closeTo(2, 0.0001));
      expect((crop.width * 0.5) / crop.height, closeTo(1, 0.0001));
    });

    test('square ratio is visually square for a landscape image', () {
      final controller = ImageEditorController();

      controller.setImageAspectRatio(2);
      controller.setRatio(CropRatio.square);

      final crop = controller.value.cropRect;
      expect(crop.width / crop.height, closeTo(0.5, 0.0001));
      expect((crop.width * 2) / crop.height, closeTo(1, 0.0001));
    });

    test('vertical flip preserves the active horizontal flip', () {
      final controller = ImageEditorController();

      controller.flipHorizontal();
      controller.flipVertical();

      expect(controller.value.flipDirection, FlipDirection.both);
    });
  });
}

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pipeline Exception Handling', () {
    const channel = MethodChannel('image_crop_compress');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'crop') {
          throw PlatformException(
            code: 'CROP_ERROR',
            message: 'Failed to decode image',
            details: 'Out of memory',
          );
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('PlatformException is caught and wrapped in ImageProcessorException', () async {
      final pipeline = Pipeline();
      pipeline.addOperation(const CropOperation(
        CropResult(
          cropRect: Rect.fromLTWH(0, 0, 1, 1),
          rotation: 0.0,
          flippedX: false,
          flippedY: false,
          ratio: CropRatio.free,
        ),
      ));

      final mockImage = ProcessedImage(
        file: File('fake.jpg'),
        bytes: Uint8List(0),
        path: 'fake.jpg',
        extension: 'jpg',
        mimeType: 'image/jpeg',
        width: 100,
        height: 100,
        sizeInBytes: 0,
      );

      try {
        await pipeline.execute(mockImage);
        fail('Should have thrown ImageProcessorException');
      } on ImageProcessorException catch (e) {
        expect(e.operationName, 'Crop');
        expect(e.code, 'CROP_ERROR');
        expect(e.message, 'Failed to decode image');
        expect(e.details, 'Out of memory');
        expect(
          e.toString(),
          'ImageProcessorException (Operation: Crop) [CROP_ERROR]: Failed to decode image',
        );
      }
    });
  });
}

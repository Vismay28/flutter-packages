import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_crop_compress_core/image_crop_compress_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageProcessorPlatform', () {
    test('default instance is MethodChannelImageProcessor', () {
      expect(
        ImageProcessorPlatform.instance,
        isA<MethodChannelImageProcessor>(),
      );
    });

    test('getPlatformVersion returns platform string', () async {
      // Set up mock method channel
      const channel = MethodChannel('image_crop_compress');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getPlatformVersion') {
          return 'Android 14';
        }
        return null;
      });

      final version =
          await ImageProcessorPlatform.instance.getPlatformVersion();
      expect(version, 'Android 14');

      // Clean up
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('unimplemented methods throw UnimplementedError', () {
      // Create a bare platform instance (not the MethodChannel one)
      // by using a custom subclass
      final platform = _TestPlatform();
      expect(
        () => platform.crop(
          sourcePath: '/test.jpg',
          cropX: 0.0,
          cropY: 0.0,
          cropWidth: 1.0,
          cropHeight: 1.0,
        ),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => platform.compress(sourcePath: '/test.jpg'),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => platform.resize(sourcePath: '/test.jpg'),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => platform.convert(
          sourcePath: '/test.jpg',
          targetFormat: 'png',
        ),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => platform.stripMetadata(sourcePath: '/test.jpg'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}

/// A minimal test implementation that exposes the base class's
/// default (throwing) method implementations.
class _TestPlatform extends ImageProcessorPlatform {}

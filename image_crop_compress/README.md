# image_crop_compress

A Flutter image-editing toolkit with a native Android and iOS processing
pipeline and an adaptive crop editor. Crop, rotate, flip, resize, compress,
convert, and strip metadata while returning a consistent `ProcessedImage`.

## Features

- Interactive crop editor with freeform and fixed aspect ratios
- 90-degree rotation and horizontal or vertical flipping
- Native crop, resize, compression, format conversion, and metadata stripping
- Fluent pipeline API and an imperative controller API
- Adaptive phone, tablet, foldable, and desktop editor layouts
- Optional compression: preserve quality by default, set a quality percentage,
  or opt into a maximum file size
- Export result includes the output `File`, absolute `path`, and in-memory bytes

## Screenshots

Add project screenshots to an `assets/screenshots/` directory and replace the
paths below with the final image names before publishing.

### Phone

| Crop editor | Aspect-ratio picker |
| --- | --- |
| _Add `phone-editor.png` here_ | _Add `phone-ratio-picker.png` here_ |

### Tablet

| Portrait | Landscape |
| --- | --- |
| _Add `tablet-portrait.png` here_ | _Add `tablet-landscape.png` here_ |

## Installation

```yaml
dependencies:
  image_crop_compress: ^0.0.1
```

Then run:

```sh
flutter pub get
```

## Interactive editor

Use `ImageEditor` when you want the built-in crop UI. The result callback
receives a `ProcessedImage` after the user taps **Done**.

```dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image_crop_compress/image_crop_compress.dart';

final image = File(sourcePath);

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ImageEditor(
      image: image,
      // Off by default: the original quality is preserved unless you opt in.
      enableCompression: true,
      maxSizeKB: 512,
      // Optional starting quality. The encoder lowers it only if needed to
      // meet maxSizeKB.
      compressionQuality: 90,
      onComplete: (result) {
        final File outputFile = result.file;
        final String outputPath = result.path;
        final Uint8List outputBytes = result.bytes;
      },
      onCancel: () => Navigator.of(context).pop(),
    ),
  ),
);
```

The editor toolbar provides clockwise rotation, horizontal flip, aspect-ratio
selection, vertical flip, and reset. Fixed ratios, including `1:1`, are drawn
in the correct physical proportions for portrait and landscape images.

## Fluent processing pipeline

Build a processing sequence when your app already has its own UI.

```dart
import 'dart:io';
import 'dart:ui';

import 'package:image_crop_compress/image_crop_compress.dart';

final result = await ImageProcessor(File(sourcePath))
    .crop(
      rect: const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8),
      ratio: CropRatio.square,
    )
    .rotate(degrees: 90)
    .flip(FlipDirection.horizontal)
    .resize(width: 1080)
    .compress(quality: 85)
    .convert(ImageFormat.jpeg)
    .stripMetadata()
    .save();
```

Crop rectangles use normalized coordinates: `0.0` is the start of an axis and
`1.0` is the end. For example, `Rect.fromLTWH(0.25, 0.25, 0.5, 0.5)` selects
the centered half of an image.

## Compression choices

Compression is never mandatory.

```dart
// No compression: omit compress().
final untouchedQuality = await ImageProcessor(file).save();

// Quality-based output (1–100).
final qualityBased = await ImageProcessor(file).compress(quality: 85).save();

// Size-based output. The native encoder progressively lowers quality as needed.
final sizeBased = await ImageProcessor(file).compress(maxSizeKB: 512).save();

// Start at a requested quality, then enforce a maximum size if necessary.
final bounded = await ImageProcessor(file)
    .compress(quality: 90, maxSizeKB: 512)
    .save();
```

In `ImageEditor`, `enableCompression` defaults to `false`. Set it to `true`
only when a maximum output size is required; `maxSizeKB` defaults to 512 and
can be changed for each editor instance. If it remains false, an optional
`compressionQuality` is used as the requested percentage without a size cap.

## Export result

Every successful operation returns `ProcessedImage`, which exposes all common
handoff forms without choosing one at the API boundary:

```dart
final ProcessedImage result = await ImageProcessor(file).save();

result.file;        // File — best for APIs that upload from disk
result.path;        // String — best for persisting or passing a path
result.bytes;       // Uint8List — best for in-memory uploads or previews
result.width;
result.height;
result.mimeType;
result.sizeInBytes;
```

Keeping the three representations together is the most scalable option:
native processing writes a reliable temporary output file once, while callers
can choose disk-backed, path-based, or in-memory integration without repeating
the image work.

## Imperative controller

For a custom editor, use `ImageProcessorController`:

```dart
final controller = ImageProcessorController();
await controller.open(file);
controller.rotateRight();
controller.setRatio(CropRatio.square);

final result = await controller.export(
  compressQuality: 85,
  // Omit both compression parameters to avoid compression.
);
```

## Platform support

| Platform | Support |
| --- | --- |
| Android | Native implementation |
| iOS | Native implementation |
| Web | Not supported |

## License

BSD 3-Clause. See [LICENSE](LICENSE).

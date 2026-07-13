# image_crop_compress

A high-performance, native-first Flutter image processing toolkit. 

Built to solve the core problem of image manipulation in Flutter: doing heavy lifting like cropping, rotating, scaling, and compressing without blocking the UI thread or running out of memory on low-end devices.

By offloading the actual pixel manipulation to the underlying iOS (Swift) and Android (Kotlin) APIs, `image_crop_compress` gives you buttery-smooth performance while providing a beautiful, out-of-the-box adaptive crop editor UI.

## Why this package?

**Advantages:**
* **Native Performance**: Pixel manipulation happens on the native side. Dart doesn't have to decode/encode large JPEGs, saving memory and keeping your 60/120fps animations smooth.
* **Pro-level UI Built-in**: Stop reinventing the wheel. We include a fully responsive, highly-customizable `ImageEditor` that adapts to Phones, Tablets, and Desktops out of the box.
* **Auto-Zoom & Gestures**: The crop editor includes advanced features like iOS-style auto-zoom when adjusting crop bounds, and flawless rotation tracking.
* **Smart Compression**: Compress by quality (e.g. 85%) OR by size constraint (e.g. "Keep this under 512KB").

**Tradeoffs & Fallbacks:**
* *Platform Support*: Because this relies on heavy native optimizations, it currently only supports Android and iOS. Web and Desktop (macOS/Windows/Linux) support are not currently available. 
* *Bundle Size*: While the native libraries are lightweight, this is not a pure-Dart package.

---

## 📸 Previews

> *(Screenshots coming soon...)*

### Phone Layout
> *(Coming soon...)*

### Tablet Layout
> *(Coming soon...)*

---

## 🛠 Installation

### 1. Requirements
* **iOS**: iOS 13.0 or higher *(technically supports down to iOS 11.0 for legacy apps)*
* **Android**: Android 10 (API 29) or higher *(technically supports down to Android 5.0 API 21 for legacy apps)*

*(No special AndroidManifest.xml or Info.plist permissions are required by this package directly unless you are picking files from the gallery/camera, which you should handle using a separate package like `image_picker`).*

### 2. Add Dependency
Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  image_crop_compress: ^0.0.1
```

Or just run this in your terminal:
```bash
flutter pub add image_crop_compress
```

### 3. Import
```dart
import 'package:image_crop_compress/image_crop_compress.dart';
```

---

## 🚀 Usage

### Option 1: The Interactive UI (Recommended)
If you want to give your users an interactive cropping and editing screen, use the `ImageEditor` widget. 

Simply push it to your navigator. Once the user clicks "Done", the `onComplete` callback fires with the processed file.

```dart
import 'dart:io';
import 'package:image_crop_compress/image_crop_compress.dart';

void openEditor(BuildContext context, File sourceFile) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ImageEditor(
        image: sourceFile,
        // (Optional) Enforce a maximum file size in KB!
        enableCompression: true,
        maxSizeKB: 1024, // Keep under 1 MB
        
        onComplete: (ProcessedImage result) {
          print("Saved to: ${result.path}");
          print("Size: ${result.sizeInBytes} bytes");
          
          // Do something with result.file or result.bytes
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    ),
  );
}
```

#### Theming the UI
The `ImageEditor` is fully themeable to match your app's design system:
```dart
ImageEditor(
  image: sourceFile,
  theme: ImageEditorTheme.dark().copyWith(
    // Customize colors, icons, appbar widgets, etc.
  ),
  onComplete: ...
)
```

### Option 2: Headless Processing Pipeline
If you already have your own UI and just need the raw processing power, use the fluent `ImageProcessor` API.

```dart
final result = await ImageProcessor(File(sourcePath))
    .crop(
      rect: const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8),
      ratio: CropRatio.square,
    )
    .rotate(degrees: 90)
    .flip(FlipDirection.horizontal)
    .resize(width: 1080)
    .compress(quality: 85, maxSizeKB: 512)
    .convert(ImageFormat.jpeg)
    .stripMetadata()
    .save();
```

---

## 📦 The `ProcessedImage` Object
Every successful crop or compression returns a `ProcessedImage` object, which gives you multiple ways to access the final image without unnecessary conversions:

```dart
result.file;        // File - Best for APIs that upload straight from disk
result.path;        // String - Best for saving to a database
result.bytes;       // Uint8List - Best for showing a quick preview in memory
result.width;       // int
result.height;      // int
result.mimeType;    // String
```

---

## License
BSD 3-Clause. See [LICENSE](LICENSE).

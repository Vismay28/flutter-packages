# image_crop_compress_android

Android implementation for `image_crop_compress`.

This federated plugin is automatically registered by Flutter when an app
depends on the app-facing `image_crop_compress` package. It provides native
crop, rotation, flip, resize, compression, conversion, and metadata stripping
through Android's bitmap and EXIF APIs.

Applications should depend on `image_crop_compress`, not this implementation
package directly.

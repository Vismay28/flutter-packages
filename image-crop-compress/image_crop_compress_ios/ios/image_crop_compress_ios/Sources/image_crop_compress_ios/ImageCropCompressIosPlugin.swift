import Flutter
import UIKit

/// iOS plugin for image_crop_compress.
///
/// Handles method channel communication between Flutter and native iOS
/// image processing engines. Dispatches calls to specialized engine classes:
///
/// - ``CropEngine`` — Image cropping using CGImage/CGContext
/// - ``CompressEngine`` — JPEG/PNG compression with smart sizing
/// - ``ResizeEngine`` — Image resizing with UIGraphicsImageRenderer
/// - ``ConvertEngine`` — Format conversion via CGImageDestination
/// - ``MetadataEngine`` — EXIF/GPS metadata stripping via CGImageSource
///
/// Channel name: `image_crop_compress`
public class ImageCropCompressIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "image_crop_compress",
            binaryMessenger: registrar.messenger()
        )
        let instance = ImageCropCompressIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "crop":
            CropEngine.handle(call, result: result)
        case "compress":
            CompressEngine.handle(call, result: result)
        case "resize":
            ResizeEngine.handle(call, result: result)
        case "convert":
            ConvertEngine.handle(call, result: result)
        case "stripMetadata":
            MetadataEngine.handle(call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

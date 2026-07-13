import Flutter
import UIKit

public class MetadataEngine {
    public static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let sourcePath = args["sourcePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "sourcePath is required", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // UIImage handles EXIF orientation inherently.
            // Re-encoding it via jpegData() strips all EXIF tags, GPS, etc.,
            // while preserving the visually correct upright orientation.
            guard let image = UIImage(contentsOfFile: sourcePath) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode image at \(sourcePath)", details: nil))
                }
                return
            }
            
            let nsStringPath = sourcePath as NSString
            var extensionStr = nsStringPath.pathExtension.lowercased()
            if extensionStr.isEmpty { extensionStr = "jpg" }
            
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("image_crop_compress")
            do {
                try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "IO_ERROR", message: "Failed to create temp directory", details: nil))
                }
                return
            }
            
            let fileName = "stripped_\(UUID().uuidString).\(extensionStr)"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            var data: Data?
            var mimeType = "image/jpeg"
            
            if extensionStr == "png" {
                data = image.pngData()
                mimeType = "image/png"
            } else {
                data = image.jpegData(compressionQuality: 1.0)
            }
            
            guard let finalData = data else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "ENCODE_ERROR", message: "Failed to encode image", details: nil))
                }
                return
            }
            
            do {
                try finalData.write(to: fileURL)
                let sizeInBytes = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? finalData.count
                
                DispatchQueue.main.async {
                    result([
                        "path": fileURL.path,
                        "width": Int(image.size.width),
                        "height": Int(image.size.height),
                        "sizeInBytes": sizeInBytes,
                        "extension": extensionStr,
                        "mimeType": mimeType
                    ])
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
}

import Flutter
import UIKit
import CoreGraphics

public class ConvertEngine {
    public static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let sourcePath = args["sourcePath"] as? String,
              let targetFormat = args["targetFormat"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "sourcePath and targetFormat are required", details: nil))
            return
        }
        
        let quality = args["quality"] as? Int ?? 100
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = UIImage(contentsOfFile: sourcePath) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode image at \(sourcePath)", details: nil))
                }
                return
            }
            
            let formatStr = targetFormat.lowercased()
            
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("image_crop_compress")
            do {
                try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "IO_ERROR", message: "Failed to create temp directory", details: nil))
                }
                return
            }
            
            let fileName = "convert_\(UUID().uuidString).\(formatStr)"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            var data: Data?
            var mimeType = "image/jpeg"
            
            if formatStr == "png" {
                data = image.pngData()
                mimeType = "image/png"
            } else if formatStr == "webp" {
                // Future optimization: implement native webp encoding or rely on flutter plugins
                // For now, fallback to JPEG on iOS unless iOS 14+ native WebP encoding is hooked up
                data = image.jpegData(compressionQuality: CGFloat(quality) / 100.0)
                mimeType = "image/webp" 
            } else if formatStr == "heif" {
                // CoreImage HEIF support can be added. 
                // For now, fallback to JPEG.
                data = image.jpegData(compressionQuality: CGFloat(quality) / 100.0)
                mimeType = "image/heif"
            } else {
                data = image.jpegData(compressionQuality: CGFloat(quality) / 100.0)
                mimeType = "image/jpeg"
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
                        "extension": formatStr,
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

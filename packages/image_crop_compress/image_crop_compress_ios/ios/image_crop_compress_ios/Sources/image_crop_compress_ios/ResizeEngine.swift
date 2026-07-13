import Flutter
import UIKit
import CoreGraphics

public class ResizeEngine {
    public static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let sourcePath = args["sourcePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "sourcePath is required", details: nil))
            return
        }
        
        let targetWidth = args["width"] as? Int
        let targetHeight = args["height"] as? Int
        let maintainAspectRatio = args["maintainAspectRatio"] as? Bool ?? true
        
        if targetWidth == nil && targetHeight == nil {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Must provide width or height", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = UIImage(contentsOfFile: sourcePath) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode image at \(sourcePath)", details: nil))
                }
                return
            }
            
            let originalWidth = image.size.width
            let originalHeight = image.size.height
            
            var finalWidth = targetWidth != nil ? CGFloat(targetWidth!) : originalWidth
            var finalHeight = targetHeight != nil ? CGFloat(targetHeight!) : originalHeight
            
            if maintainAspectRatio {
                if targetWidth != nil && targetHeight == nil {
                    let ratio = finalWidth / originalWidth
                    finalHeight = originalHeight * ratio
                } else if targetHeight != nil && targetWidth == nil {
                    let ratio = finalHeight / originalHeight
                    finalWidth = originalWidth * ratio
                } else if targetWidth != nil && targetHeight != nil {
                    let ratioW = finalWidth / originalWidth
                    let ratioH = finalHeight / originalHeight
                    let minRatio = min(ratioW, ratioH)
                    finalWidth = originalWidth * minRatio
                    finalHeight = originalHeight * minRatio
                }
            }
            
            let newSize = CGSize(width: finalWidth, height: finalHeight)
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0 // Output at exact pixel dimensions
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            
            let resizedImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
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
            
            let fileName = "resize_\(UUID().uuidString).\(extensionStr)"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            var data: Data?
            var mimeType = "image/jpeg"
            
            if extensionStr == "png" {
                data = resizedImage.pngData()
                mimeType = "image/png"
            } else {
                data = resizedImage.jpegData(compressionQuality: 1.0)
            }
            
            guard let finalData = data else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "ENCODE_ERROR", message: "Failed to encode resized image", details: nil))
                }
                return
            }
            
            do {
                try finalData.write(to: fileURL)
                let sizeInBytes = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? finalData.count
                
                DispatchQueue.main.async {
                    result([
                        "path": fileURL.path,
                        "width": Int(newSize.width),
                        "height": Int(newSize.height),
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

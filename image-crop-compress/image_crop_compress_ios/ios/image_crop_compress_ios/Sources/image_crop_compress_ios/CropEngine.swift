import Flutter
import UIKit
import CoreGraphics
import AVFoundation

public class CropEngine {
    public static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let sourcePath = args["sourcePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "sourcePath is required", details: nil))
            return
        }
        
        let cropX = args["cropX"] as? Double ?? 0.0
        let cropY = args["cropY"] as? Double ?? 0.0
        let cropWidth = args["cropWidth"] as? Double ?? 1.0
        let cropHeight = args["cropHeight"] as? Double ?? 1.0
        let rotation = args["rotation"] as? Double ?? 0.0
        let flipX = args["flipX"] as? Bool ?? false
        let flipY = args["flipY"] as? Bool ?? false
        let outputQuality = args["outputQuality"] as? Int ?? 100
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = UIImage(contentsOfFile: sourcePath),
                  let cgImage = image.cgImage else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode image at \(sourcePath)", details: nil))
                }
                return
            }
            
            let originalWidth = CGFloat(cgImage.width)
            let originalHeight = CGFloat(cgImage.height)
            
            // 1. Calculate pixel rect
            let pixelX = max(0, min(originalWidth, CGFloat(cropX) * originalWidth))
            let pixelY = max(0, min(originalHeight, CGFloat(cropY) * originalHeight))
            let pixelWidth = max(1, min(originalWidth - pixelX, CGFloat(cropWidth) * originalWidth))
            let pixelHeight = max(1, min(originalHeight - pixelY, CGFloat(cropHeight) * originalHeight))
            
            let cropRect = CGRect(x: pixelX, y: pixelY, width: pixelWidth, height: pixelHeight)
            
            // 2. Crop the image first
            guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CROP_ERROR", message: "Failed to crop CGImage", details: nil))
                }
                return
            }
            
            // 3. Setup context for transform
            var targetWidth = CGFloat(croppedCGImage.width)
            var targetHeight = CGFloat(croppedCGImage.height)
            
            // Swap width and height if rotated by 90 or 270 degrees
            let absoluteRotation = abs(rotation.truncatingRemainder(dividingBy: 360.0))
            if absoluteRotation == 90.0 || absoluteRotation == 270.0 {
                targetWidth = CGFloat(croppedCGImage.height)
                targetHeight = CGFloat(croppedCGImage.width)
            }
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetWidth, height: targetHeight), format: format)
            
            let finalImage = renderer.image { context in
                let ctx = context.cgContext
                
                // Move origin to center
                ctx.translateBy(x: targetWidth / 2.0, y: targetHeight / 2.0)
                
                // Rotation
                if rotation != 0.0 {
                    ctx.rotate(by: CGFloat(rotation) * .pi / 180.0)
                }
                
                // Flip
                let scaleX: CGFloat = flipX ? -1.0 : 1.0
                let scaleY: CGFloat = flipY ? -1.0 : 1.0
                if flipX || flipY {
                    ctx.scaleBy(x: scaleX, y: scaleY)
                }
                
                // UIKit's coordinate system is flipped compared to CGImage, so we flip vertically to draw properly,
                // but since we are drawing a CGImage into UIKit context which expects UIImage, we need to adjust.
                // UIGraphicsImageRenderer is a UIKit wrapper, but we'll draw a CGImage.
                ctx.scaleBy(x: 1.0, y: -1.0)
                
                let drawRect = CGRect(x: -CGFloat(croppedCGImage.width) / 2.0,
                                      y: -CGFloat(croppedCGImage.height) / 2.0,
                                      width: CGFloat(croppedCGImage.width),
                                      height: CGFloat(croppedCGImage.height))
                
                ctx.draw(croppedCGImage, in: drawRect)
            }
            
            // 4. Save to temp file
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
            
            let fileName = "crop_\(UUID().uuidString).\(extensionStr)"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            var data: Data?
            var mimeType = "image/jpeg"
            
            if extensionStr == "png" {
                data = finalImage.pngData()
                mimeType = "image/png"
            } else {
                let quality = CGFloat(outputQuality) / 100.0
                data = finalImage.jpegData(compressionQuality: quality)
            }
            
            guard let finalData = data else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "ENCODE_ERROR", message: "Failed to encode image data", details: nil))
                }
                return
            }
            
            do {
                try finalData.write(to: fileURL)
                
                let sizeInBytes = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? finalData.count
                
                DispatchQueue.main.async {
                    result([
                        "path": fileURL.path,
                        "width": Int(finalImage.size.width),
                        "height": Int(finalImage.size.height),
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

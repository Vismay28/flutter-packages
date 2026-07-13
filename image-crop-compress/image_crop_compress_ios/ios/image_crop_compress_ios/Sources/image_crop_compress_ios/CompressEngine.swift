import Flutter
import UIKit
import CoreGraphics

public class CompressEngine {
    public static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let sourcePath = args["sourcePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "sourcePath is required", details: nil))
            return
        }
        
        let initialQuality = args["quality"] as? Int
        let maxSizeKB = args["maxSizeKB"] as? Int
        
        DispatchQueue.global(qos: .userInitiated).async {
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
            
            let fileName = "compress_\(UUID().uuidString).\(extensionStr)"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            var data: Data?
            var mimeType = "image/jpeg"
            var finalQuality = initialQuality ?? 100
            
            if extensionStr == "png" {
                data = image.pngData()
                mimeType = "image/png"
            } else {
                if let maxSizeKB = maxSizeKB {
                    let targetSizeBytes = maxSizeKB * 1024
                    var currentQuality = finalQuality
                    
                    while currentQuality > 10 {
                        let qualityFloat = CGFloat(currentQuality) / 100.0
                        if let temp = image.jpegData(compressionQuality: qualityFloat) {
                            if temp.count <= targetSizeBytes {
                                data = temp
                                break
                            }
                        }
                        currentQuality -= 10
                    }
                    
                    if data == nil {
                        data = image.jpegData(compressionQuality: 0.1)
                    }
                } else {
                    data = image.jpegData(compressionQuality: CGFloat(finalQuality) / 100.0)
                }
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

package com.imageprocessor.image_crop_compress_android

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import androidx.exifinterface.media.ExifInterface
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

object CropEngine {
    fun handle(call: MethodCall, result: MethodChannel.Result, context: Context) {
        val sourcePath = call.argument<String>("sourcePath")
        val cropX = call.argument<Double>("cropX") ?: 0.0
        val cropY = call.argument<Double>("cropY") ?: 0.0
        val cropWidth = call.argument<Double>("cropWidth") ?: 1.0
        val cropHeight = call.argument<Double>("cropHeight") ?: 1.0
        val rotation = call.argument<Double>("rotation") ?: 0.0
        val flipX = call.argument<Boolean>("flipX") ?: false
        val flipY = call.argument<Boolean>("flipY") ?: false
        val outputQuality = call.argument<Int>("outputQuality") ?: 100

        if (sourcePath == null) {
            result.error("INVALID_ARGUMENT", "sourcePath is required", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                // 1. Decode bitmap
                val options = BitmapFactory.Options()
                options.inPreferredConfig = Bitmap.Config.ARGB_8888
                var bitmap = BitmapFactory.decodeFile(sourcePath, options)
                    ?: throw Exception("Failed to decode image at $sourcePath")

                // 2. Read original EXIF rotation and apply it so the image is upright
                val exif = ExifInterface(sourcePath)
                val exifRotation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                var exifDegrees = 0f
                when (exifRotation) {
                    ExifInterface.ORIENTATION_ROTATE_90 -> exifDegrees = 90f
                    ExifInterface.ORIENTATION_ROTATE_180 -> exifDegrees = 180f
                    ExifInterface.ORIENTATION_ROTATE_270 -> exifDegrees = 270f
                }
                
                // 3. Setup Matrix for rotation and flip
                val matrix = Matrix()
                if (exifDegrees != 0f) {
                    matrix.postRotate(exifDegrees)
                }
                if (rotation != 0.0) {
                    matrix.postRotate(rotation.toFloat())
                }
                if (flipX || flipY) {
                    matrix.postScale(if (flipX) -1f else 1f, if (flipY) -1f else 1f)
                }

                // 4. Calculate crop rectangle in pixel coordinates
                val originalWidth = bitmap.width
                val originalHeight = bitmap.height
                val pixelX = (cropX * originalWidth).toInt().coerceIn(0, originalWidth)
                val pixelY = (cropY * originalHeight).toInt().coerceIn(0, originalHeight)
                val pixelWidth = (cropWidth * originalWidth).toInt().coerceIn(1, originalWidth - pixelX)
                val pixelHeight = (cropHeight * originalHeight).toInt().coerceIn(1, originalHeight - pixelY)

                // 5. Apply crop, rotation, and flip in one step
                val croppedBitmap = Bitmap.createBitmap(
                    bitmap, pixelX, pixelY, pixelWidth, pixelHeight, matrix, true
                )

                // 6. Save to temp file
                val extension = File(sourcePath).extension.lowercase().let { 
                    if (it.isEmpty()) "jpg" else it 
                }
                
                val compressFormat = when (extension) {
                    "png" -> Bitmap.CompressFormat.PNG
                    "webp" -> if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R)
                        Bitmap.CompressFormat.WEBP_LOSSY
                    else
                        @Suppress("DEPRECATION") Bitmap.CompressFormat.WEBP
                    else -> Bitmap.CompressFormat.JPEG
                }

                val tempDir = File(context.cacheDir, "image_crop_compress")
                if (!tempDir.exists()) tempDir.mkdirs()
                
                val outputFile = File(tempDir, "crop_${UUID.randomUUID()}.$extension")
                FileOutputStream(outputFile).use { out ->
                    croppedBitmap.compress(compressFormat, outputQuality, out)
                }

                val sizeInBytes = outputFile.length()
                val finalWidth = croppedBitmap.width
                val finalHeight = croppedBitmap.height

                // Cleanup
                if (bitmap != croppedBitmap) {
                    bitmap.recycle()
                }
                croppedBitmap.recycle()

                val mimeType = when (compressFormat) {
                    Bitmap.CompressFormat.PNG -> "image/png"
                    Bitmap.CompressFormat.JPEG -> "image/jpeg"
                    else -> "image/webp"
                }

                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "path" to outputFile.absolutePath,
                        "width" to finalWidth,
                        "height" to finalHeight,
                        "sizeInBytes" to sizeInBytes,
                        "extension" to extension,
                        "mimeType" to mimeType
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("CROP_ERROR", e.message, null)
                }
            }
        }
    }
}

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

object MetadataEngine {
    fun handle(call: MethodCall, result: MethodChannel.Result, context: Context) {
        val sourcePath = call.argument<String>("sourcePath")

        if (sourcePath == null) {
            result.error("INVALID_ARGUMENT", "sourcePath is required", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                // 1. Read EXIF rotation before stripping
                val exif = ExifInterface(sourcePath)
                val exifRotation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                var exifDegrees = 0f
                when (exifRotation) {
                    ExifInterface.ORIENTATION_ROTATE_90 -> exifDegrees = 90f
                    ExifInterface.ORIENTATION_ROTATE_180 -> exifDegrees = 180f
                    ExifInterface.ORIENTATION_ROTATE_270 -> exifDegrees = 270f
                }

                // 2. Decode bitmap
                var bitmap = BitmapFactory.decodeFile(sourcePath)
                    ?: throw Exception("Failed to decode image at $sourcePath")

                // 3. Apply rotation if needed to bake in the correct visual orientation
                if (exifDegrees != 0f) {
                    val matrix = Matrix()
                    matrix.postRotate(exifDegrees)
                    val rotatedBitmap = Bitmap.createBitmap(
                        bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true
                    )
                    if (bitmap != rotatedBitmap) {
                        bitmap.recycle()
                        bitmap = rotatedBitmap
                    }
                }

                // 4. Save to a new file (Android's compress() drops EXIF naturally)
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
                val outputFile = File(tempDir, "stripped_${UUID.randomUUID()}.$extension")

                FileOutputStream(outputFile).use { out ->
                    bitmap.compress(compressFormat, 100, out)
                }

                val sizeInBytes = outputFile.length()
                val width = bitmap.width
                val height = bitmap.height
                bitmap.recycle()

                val mimeType = when (compressFormat) {
                    Bitmap.CompressFormat.PNG -> "image/png"
                    Bitmap.CompressFormat.JPEG -> "image/jpeg"
                    else -> "image/webp"
                }

                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "path" to outputFile.absolutePath,
                        "width" to width,
                        "height" to height,
                        "sizeInBytes" to sizeInBytes,
                        "extension" to extension,
                        "mimeType" to mimeType
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("METADATA_ERROR", e.message, null)
                }
            }
        }
    }
}

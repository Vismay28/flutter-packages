package com.imageprocessor.image_crop_compress_android

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

object ConvertEngine {
    fun handle(call: MethodCall, result: MethodChannel.Result, context: Context) {
        val sourcePath = call.argument<String>("sourcePath")
        val targetFormatString = call.argument<String>("targetFormat")
        val quality = call.argument<Int>("quality") ?: 100

        if (sourcePath == null || targetFormatString == null) {
            result.error("INVALID_ARGUMENT", "sourcePath and targetFormat are required", null)
            return
        }

        val compressFormat = when (targetFormatString.lowercase()) {
            "png" -> Bitmap.CompressFormat.PNG
            "webp" -> if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R)
                Bitmap.CompressFormat.WEBP_LOSSY
            else
                @Suppress("DEPRECATION") Bitmap.CompressFormat.WEBP
            "heif" -> if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R)
                Bitmap.CompressFormat.WEBP_LOSSY // Fallback since native HEIF encoding is complex
            else Bitmap.CompressFormat.JPEG // Fallback
            else -> Bitmap.CompressFormat.JPEG
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val bitmap = BitmapFactory.decodeFile(sourcePath)
                    ?: throw Exception("Failed to decode image at $sourcePath")

                val tempDir = File(context.cacheDir, "image_crop_compress")
                if (!tempDir.exists()) tempDir.mkdirs()
                val outputFile = File(tempDir, "convert_${UUID.randomUUID()}.$targetFormatString")

                FileOutputStream(outputFile).use { out ->
                    bitmap.compress(compressFormat, quality, out)
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
                        "extension" to targetFormatString,
                        "mimeType" to mimeType
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("CONVERT_ERROR", e.message, null)
                }
            }
        }
    }
}

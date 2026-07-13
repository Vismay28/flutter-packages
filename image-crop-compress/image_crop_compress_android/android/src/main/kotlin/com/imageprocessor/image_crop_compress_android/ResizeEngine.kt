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

object ResizeEngine {
    fun handle(call: MethodCall, result: MethodChannel.Result, context: Context) {
        val sourcePath = call.argument<String>("sourcePath")
        val targetWidth = call.argument<Int>("width")
        val targetHeight = call.argument<Int>("height")
        val maintainAspectRatio = call.argument<Boolean>("maintainAspectRatio") ?: true

        if (sourcePath == null) {
            result.error("INVALID_ARGUMENT", "sourcePath is required", null)
            return
        }

        if (targetWidth == null && targetHeight == null) {
            result.error("INVALID_ARGUMENT", "Must provide width or height", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val bitmap = BitmapFactory.decodeFile(sourcePath)
                    ?: throw Exception("Failed to decode image at $sourcePath")

                val originalWidth = bitmap.width
                val originalHeight = bitmap.height

                var finalWidth = targetWidth ?: originalWidth
                var finalHeight = targetHeight ?: originalHeight

                if (maintainAspectRatio) {
                    if (targetWidth != null && targetHeight == null) {
                        val ratio = targetWidth.toFloat() / originalWidth
                        finalHeight = (originalHeight * ratio).toInt()
                    } else if (targetHeight != null && targetWidth == null) {
                        val ratio = targetHeight.toFloat() / originalHeight
                        finalWidth = (originalWidth * ratio).toInt()
                    } else if (targetWidth != null && targetHeight != null) {
                        val ratioW = targetWidth.toFloat() / originalWidth
                        val ratioH = targetHeight.toFloat() / originalHeight
                        val minRatio = kotlin.math.min(ratioW, ratioH)
                        finalWidth = (originalWidth * minRatio).toInt()
                        finalHeight = (originalHeight * minRatio).toInt()
                    }
                }

                val resizedBitmap = Bitmap.createScaledBitmap(bitmap, finalWidth, finalHeight, true)

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
                val outputFile = File(tempDir, "resize_${UUID.randomUUID()}.$extension")

                FileOutputStream(outputFile).use { out ->
                    resizedBitmap.compress(compressFormat, 100, out)
                }

                val sizeInBytes = outputFile.length()
                if (bitmap != resizedBitmap) {
                    bitmap.recycle()
                }
                resizedBitmap.recycle()

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
                    result.error("RESIZE_ERROR", e.message, null)
                }
            }
        }
    }
}

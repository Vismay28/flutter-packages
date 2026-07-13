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
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.UUID
import kotlin.math.max

object CompressEngine {
    fun handle(call: MethodCall, result: MethodChannel.Result, context: Context) {
        val sourcePath = call.argument<String>("sourcePath")
        val initialQuality = call.argument<Int>("quality")
        val maxSizeKB = call.argument<Int>("maxSizeKB")

        if (sourcePath == null) {
            result.error("INVALID_ARGUMENT", "sourcePath is required", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val file = File(sourcePath)
                val extension = file.extension.lowercase().let { 
                    if (it.isEmpty()) "jpg" else it 
                }
                
                // Decode bounds just to check if we can skip some processing
                val options = BitmapFactory.Options()
                var bitmap = BitmapFactory.decodeFile(sourcePath, options)
                    ?: throw Exception("Failed to decode image at $sourcePath")

                val compressFormat = when (extension) {
                    "png" -> Bitmap.CompressFormat.PNG // PNG ignores quality, so compression won't work well
                    "webp" -> if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R)
                        Bitmap.CompressFormat.WEBP_LOSSY
                    else
                        @Suppress("DEPRECATION") Bitmap.CompressFormat.WEBP
                    else -> Bitmap.CompressFormat.JPEG
                }

                val tempDir = File(context.cacheDir, "image_crop_compress")
                if (!tempDir.exists()) tempDir.mkdirs()
                val outputFile = File(tempDir, "compress_${UUID.randomUUID()}.$extension")

                var finalQuality = initialQuality ?: 100
                var sizeInBytes = file.length()
                var currentQuality = finalQuality

                if (maxSizeKB != null) {
                    val targetSizeBytes = maxSizeKB * 1024L
                    
                    // Smart compression loop
                    while (currentQuality > 10) {
                        val stream = ByteArrayOutputStream()
                        bitmap.compress(compressFormat, currentQuality, stream)
                        val compressedSize = stream.toByteArray().size
                        
                        if (compressedSize <= targetSizeBytes) {
                            FileOutputStream(outputFile).use { out ->
                                stream.writeTo(out)
                            }
                            sizeInBytes = compressedSize.toLong()
                            break
                        }
                        
                        // Drop quality
                        currentQuality -= 10
                    }
                    
                    // If we reached min quality and still didn't save, just save at 10
                    if (!outputFile.exists()) {
                        FileOutputStream(outputFile).use { out ->
                            bitmap.compress(compressFormat, 10, out)
                        }
                        sizeInBytes = outputFile.length()
                    }
                } else {
                    // Just compress once at given quality
                    FileOutputStream(outputFile).use { out ->
                        bitmap.compress(compressFormat, currentQuality, out)
                    }
                    sizeInBytes = outputFile.length()
                }

                val finalWidth = bitmap.width
                val finalHeight = bitmap.height
                bitmap.recycle()

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
                    result.error("COMPRESS_ERROR", e.message, null)
                }
            }
        }
    }
}

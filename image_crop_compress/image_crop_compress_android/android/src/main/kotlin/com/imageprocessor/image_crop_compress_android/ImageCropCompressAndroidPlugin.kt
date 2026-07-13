package com.imageprocessor.image_crop_compress_android

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Android plugin for image_crop_compress.
 *
 * Handles method channel communication between Flutter and native Android
 * image processing engines. Dispatches calls to specialized engine classes:
 *
 * - [CropEngine] — Image cropping with rotation and flip support
 * - [CompressEngine] — Quality-based and smart size-based compression
 * - [ResizeEngine] — Proportional and explicit resizing
 * - [ConvertEngine] — Format conversion (JPEG, PNG, WebP, HEIF)
 * - [MetadataEngine] — EXIF/GPS metadata stripping
 *
 * Channel name: `image_crop_compress`
 */
class ImageCropCompressAndroidPlugin :
    FlutterPlugin,
    MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: android.content.Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "image_crop_compress")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "crop" -> CropEngine.handle(call, result, context)
            "compress" -> CompressEngine.handle(call, result, context)
            "resize" -> ResizeEngine.handle(call, result, context)
            "convert" -> ConvertEngine.handle(call, result, context)
            "stripMetadata" -> MetadataEngine.handle(call, result, context)

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

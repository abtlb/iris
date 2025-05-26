package com.example.untitled3

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import xyz.zhzh.flutter_hand_tracking_plugin.HandTrackingViewFactory

class MainActivity: FlutterActivity() {
    companion object {
        init {
            if (!isEmulator()) {
                System.loadLibrary("mediapipe_jni")
            }
        }

        private fun isEmulator(): Boolean {
            return (Build.FINGERPRINT.startsWith("generic")
                    || Build.FINGERPRINT.lowercase().contains("vbox")
                    || Build.MODEL.contains("Emulator")
                    || Build.MANUFACTURER.contains("Genymotion")
                    || Build.HARDWARE.contains("goldfish")
                    || Build.PRODUCT.contains("sdk"))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register your PlatformViewFactory under the same viewType
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "plugins.zhzh.xyz/flutter_hand_tracking_plugin/view",
                HandTrackingViewFactory(
                    activity = this,
                    messenger = flutterEngine.dartExecutor.binaryMessenger
                )
            )
    }
}

package com.example.untitled3

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import xyz.zhzh.flutter_hand_tracking_plugin.HandTrackingViewFactory

class MainActivity: FlutterActivity() {
    companion object {
        init {
            // Load the native Mediapipe library
            System.loadLibrary("mediapipe_jni")
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

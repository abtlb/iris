package com.example.untitled3

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.media.AudioManager
import xyz.zhzh.flutter_hand_tracking_plugin.HandTrackingViewFactory

class MainActivity: FlutterActivity() {
    // This must match the Dart side exactly:
    private val CHANNEL = "app.audio_control"

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "muteNotification" -> {
                    val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                    // Mute notifications (where the speech-start beep is played)
                    audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_MUTE, 0)
                    result.success(null)
                }
                "unmuteNotification" -> {
                    val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                    // Unmute back
                    audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, 0)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}

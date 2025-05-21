package xyz.zhzh.flutter_hand_tracking_plugin

import android.app.Activity
import android.content.Context
import android.graphics.SurfaceTexture
import android.util.Log
import android.util.Size
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import android.widget.Toast
import androidx.annotation.NonNull
import com.google.mediapipe.components.*
import com.google.mediapipe.formats.proto.LandmarkProto
import com.google.mediapipe.framework.AndroidAssetUtil
import com.google.mediapipe.framework.Packet
import com.google.mediapipe.framework.PacketGetter
import com.google.mediapipe.glutil.EglManager
import com.google.protobuf.InvalidProtocolBufferException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry

class FlutterHandTrackingPlugin : FlutterPlugin, ActivityAware {
    companion object {
        const val TAG = "HandTrackingPlugin"
        const val NAMESPACE = "plugins.zhzh.xyz/flutter_hand_tracking_plugin"
        const val BINARY_GRAPH_NAME = "handtrackinggpu.binarypb"
        const val INPUT_VIDEO_STREAM_NAME = "input_video"
        const val OUTPUT_VIDEO_STREAM_NAME = "output_video"
        const val OUTPUT_HAND_PRESENCE_STREAM_NAME = "hand_presence"
        const val OUTPUT_LANDMARKS_STREAM_NAME = "hand_landmarks"
        val CAMERA_FACING = CameraHelper.CameraFacing.FRONT
        const val FLIP_FRAMES_VERTICALLY = true

        init {
            System.loadLibrary("mediapipe_jni")
            System.loadLibrary("opencv_java3")
        }

        private fun getLandmarksString(
            landmarks: LandmarkProto.NormalizedLandmarkList
        ): String {
            val sb = StringBuilder()
            for ((i, lm) in landmarks.landmarkList.withIndex()) {
                sb.append("\tLandmark[$i]: (${lm.x}, ${lm.y}, ${lm.z})\n")
            }
            return sb.toString()
        }
    }

    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel
    private lateinit var registry: PlatformViewRegistry
    private lateinit var messenger: BinaryMessenger

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        messenger = binding.binaryMessenger
    }

    // ActivityAware:
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        // Now that we have both engine and activity, register the view:
        registry.registerViewFactory(
            "$NAMESPACE/view",
            HandTrackingViewFactory(activity, messenger)
        )
    }

    override fun onDetachedFromActivityForConfigChanges() { /* no-op */ }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }
    override fun onDetachedFromActivity() { /* no-op */ }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up if needed
    }
}

package xyz.zhzh.flutter_hand_tracking_plugin

import android.app.Activity
import android.graphics.SurfaceTexture
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Size
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import com.google.mediapipe.components.CameraHelper
//import com.google.mediapipe.components.CameraXPreviewHelper
import com.google.mediapipe.components.EnhancedCameraXPreviewHelper
import com.google.mediapipe.components.ExternalTextureConverter
import com.google.mediapipe.components.FrameProcessor
import com.google.mediapipe.components.PermissionHelper
import com.google.mediapipe.framework.AndroidAssetUtil
import com.google.mediapipe.framework.Packet
import com.google.mediapipe.framework.PacketGetter
import com.google.mediapipe.glutil.EglManager
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView

class HandTrackingPlatformView(
    private val activity: Activity,
    messenger: io.flutter.plugin.common.BinaryMessenger,
    id: Int
) : PlatformView {
    private val TAG = "HandTrackingPlatformView"
    private val uiHandler = Handler(Looper.getMainLooper())

    // --- MediaPipe / CameraX fields ---
    private var previewFrameTexture: SurfaceTexture? = null
    private val previewDisplayView: SurfaceView = SurfaceView(activity).apply {
        visibility = View.GONE
    }
    private val eglManager = EglManager(null)
    private val processor: FrameProcessor
    private var converter: ExternalTextureConverter? = null
    private var cameraHelper: EnhancedCameraXPreviewHelper? = null
    private var handPresent: Boolean = false

    // --- Flutter EventChannel for landmarks ---
    private val eventChannel =
        EventChannel(messenger, "plugins.zhzh.xyz/flutter_hand_tracking_plugin/$id/landmarks")
    private var eventSink: EventChannel.EventSink? = null

    init {
        setupEventChannel()
        setupPreviewDisplayView()
        AndroidAssetUtil.initializeNativeAssetManager(activity)

        // Configure MediaPipe FrameProcessor
        processor = FrameProcessor(
            activity,
            eglManager.nativeContext,
            FlutterHandTrackingPlugin.BINARY_GRAPH_NAME,
            FlutterHandTrackingPlugin.INPUT_VIDEO_STREAM_NAME,
            FlutterHandTrackingPlugin.OUTPUT_VIDEO_STREAM_NAME
        )
        setupProcessorCallbacks()

        // Ask for camera permission; once granted, onResume() will start camera
        PermissionHelper.checkAndRequestCameraPermissions(activity)
    }

    private fun setupEventChannel() {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                Log.d(TAG, "Flutter started listening on EventChannel")
                eventSink = sink
                onResume()
            }

            override fun onCancel(args: Any?) {
                eventSink = null
            }
        })
    }

    private fun setupPreviewDisplayView() {
        previewDisplayView.visibility = View.GONE
        previewDisplayView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                // Once the SurfaceHolder is ready, send frames into it
                processor.videoSurfaceOutput.setSurface(holder.surface)
            }

            override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
                // When view size changes, adjust converter’s output size
                val viewSize = Size(width, height)
                cameraHelper?.let { helper ->
                    val displaySize = helper.computeDisplaySizeFromViewSize(viewSize)
                    val isCameraRotated = helper.isCameraRotated
                    converter?.setSurfaceTextureAndAttachToGLContext(
                        previewFrameTexture,
                        if (isCameraRotated) displaySize?.height ?: 0 else displaySize?.width ?: 0,
                        if (isCameraRotated) displaySize?.width ?: 0 else displaySize?.height ?: 0
                    )
                }
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                processor.videoSurfaceOutput.setSurface(null)
            }
        })
    }

    private fun setupProcessorCallbacks() {
        // Flip vertically if needed
        processor.videoSurfaceOutput.setFlipY(FlutterHandTrackingPlugin.FLIP_FRAMES_VERTICALLY)

        // Listen to hand presence (optional)
        processor.addPacketCallback(FlutterHandTrackingPlugin.OUTPUT_HAND_PRESENCE_STREAM_NAME) { packet: Packet ->
            handPresent = PacketGetter.getBool(packet)
            // You can log or ignore
        }

        // Listen to landmark packets and push to Flutter via EventChannel
        processor.addPacketCallback(FlutterHandTrackingPlugin.OUTPUT_LANDMARKS_STREAM_NAME) { packet: Packet ->
            val bytes = PacketGetter.getProtoBytes(packet)
            uiHandler.post {
                eventSink?.success(bytes)
            }
        }
    }

    private fun onResume() {
        // Create a new ExternalTextureConverter connected to the FrameProcessor
        converter = ExternalTextureConverter(eglManager.context).apply {
            setFlipY(FlutterHandTrackingPlugin.FLIP_FRAMES_VERTICALLY)
            setConsumer(processor)
        }

        // If camera permission is granted, start CameraX
        if (PermissionHelper.cameraPermissionsGranted(activity)) {
            startCamera()
        }
    }

    private fun startCamera() {
        cameraHelper = EnhancedCameraXPreviewHelper().also { helper ->
            helper.setOnCameraStartedListener { surfaceTexture: SurfaceTexture? ->
                // Called when CameraX is ready with its SurfaceTexture
                previewFrameTexture = surfaceTexture
                previewDisplayView.visibility = View.VISIBLE
            }
            // Start camera with front/back depending on your constant
            helper.startCamera(activity, FlutterHandTrackingPlugin.CAMERA_FACING, null)
        }
    }

    override fun getView(): View = previewDisplayView

    override fun dispose() {
        Log.d(TAG, "Disposing HandTrackingPlatformView")

        try {
            // 1) Clear EventChannel sink first to prevent crashes
            eventSink = null

            // 2) CRITICAL: Stop the converter BEFORE stopping the camera
            // This prevents the converter from trying to process frames from an abandoned SurfaceTexture
            try {
                converter?.close()
                converter = null
                Log.d(TAG, "Converter closed successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error closing converter", e)
            }

            // 3) Stop processor to prevent further frame processing
            try {
                // Uncomment these if you have packet callbacks registered
                // processor.removePacketCallback(FlutterHandTrackingPlugin.OUTPUT_HAND_PRESENCE_STREAM_NAME)
                // processor.removePacketCallback(FlutterHandTrackingPlugin.OUTPUT_LANDMARKS_STREAM_NAME)
                processor.close()
                Log.d(TAG, "Processor closed successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error closing processor", e)
            }

            // 4) Small delay to ensure MediaPipe components have stopped processing
            try {
                Thread.sleep(100)
            } catch (e: InterruptedException) {
                Thread.currentThread().interrupt()
            }

            // 5) Now it's safe to stop the camera
            cameraHelper?.stopCamera()
            cameraHelper = null

            // 6) Clean up surface texture after camera is stopped
            previewFrameTexture?.let { texture ->
                try {
                    texture.release()
                    Log.d(TAG, "Surface texture released")
                } catch (e: Exception) {
                    Log.e(TAG, "Error releasing surface texture", e)
                }
            }
            previewFrameTexture = null

            // 7) Release EGL manager
            try {
                eglManager.release()
                Log.d(TAG, "EGL manager released")
            } catch (e: Exception) {
                Log.e(TAG, "Error releasing EGL manager", e)
            }

            // 8) Hide the surface view
            previewDisplayView.visibility = View.GONE

            Log.d(TAG, "HandTrackingPlatformView disposed successfully")

        } catch (e: Exception) {
            Log.e(TAG, "Error during disposal", e)
        }
    }
}

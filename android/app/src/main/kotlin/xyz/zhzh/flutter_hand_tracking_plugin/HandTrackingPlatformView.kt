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
import android.widget.Toast
import com.google.mediapipe.components.*
import com.google.mediapipe.formats.proto.LandmarkProto
import com.google.mediapipe.framework.AndroidAssetUtil
import com.google.mediapipe.framework.Packet
import com.google.mediapipe.framework.PacketGetter
import com.google.mediapipe.glutil.EglManager
import com.google.protobuf.InvalidProtocolBufferException
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView

class HandTrackingPlatformView(
    private val activity: Activity,
    messenger: io.flutter.plugin.common.BinaryMessenger,
    id: Int
) : PlatformView {
    private val TAG = "HandTrackingPlatformView"
    private val uiThreadHandler = Handler(Looper.getMainLooper())
    private var previewFrameTexture: SurfaceTexture? = null
    private val previewDisplayView: SurfaceView = SurfaceView(activity)
    private val eglManager = EglManager(null)
    private val processor: FrameProcessor
    private var converter: ExternalTextureConverter? = null
    private var cameraHelper: CameraXPreviewHelper? = null

    private val eventChannel = EventChannel(messenger, "plugins.zhzh.xyz/flutter_hand_tracking_plugin/$id/landmarks")
    private var eventSink: EventChannel.EventSink? = null
    private val _id = id;

    init {
        setupEventChannel()
        setupPreviewDisplayView()
        AndroidAssetUtil.initializeNativeAssetManager(activity)
        processor = FrameProcessor(
            activity,
            eglManager.nativeContext,
            FlutterHandTrackingPlugin.BINARY_GRAPH_NAME,
            FlutterHandTrackingPlugin.INPUT_VIDEO_STREAM_NAME,
            FlutterHandTrackingPlugin.OUTPUT_VIDEO_STREAM_NAME
        )
        setupProcessorCallbacks()
        PermissionHelper.checkAndRequestCameraPermissions(activity)
//        if (PermissionHelper.cameraPermissionsGranted(activity)) onResume()
    }

    private fun setupEventChannel() {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                Log.d(TAG, "Flutter started listening on EventChannel id=$_id")
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
                processor.videoSurfaceOutput.setSurface(holder.surface)
            }
            override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
                val viewSize = Size(width, height)
                val displaySize = cameraHelper!!.computeDisplaySizeFromViewSize(viewSize)
                val isCameraRotated = cameraHelper!!.isCameraRotated
                converter!!.setSurfaceTextureAndAttachToGLContext(
                    previewFrameTexture,
                    if (isCameraRotated) displaySize.height else displaySize.width,
                    if (isCameraRotated) displaySize.width else displaySize.height
                )
            }
            override fun surfaceDestroyed(holder: SurfaceHolder) {
                processor.videoSurfaceOutput.setSurface(null)
            }
        })
    }

    private fun setupProcessorCallbacks() {
        processor.videoSurfaceOutput.setFlipY(FlutterHandTrackingPlugin.FLIP_FRAMES_VERTICALLY)
        processor.addPacketCallback(FlutterHandTrackingPlugin.OUTPUT_HAND_PRESENCE_STREAM_NAME) { packet: Packet ->
            val handPresence = PacketGetter.getBool(packet)
            if (!handPresence) {
//                Log.d(TAG, "No hands detected at TS ${packet.timestamp}")
            }
        }
        processor.addPacketCallback(FlutterHandTrackingPlugin.OUTPUT_LANDMARKS_STREAM_NAME) { packet: Packet ->
            val bytes = PacketGetter.getProtoBytes(packet)
                uiThreadHandler.post {
                eventSink?.success(bytes)
            }
        }
    }

    private fun onResume() {
        converter = ExternalTextureConverter(eglManager.context).apply {
            setFlipY(FlutterHandTrackingPlugin.FLIP_FRAMES_VERTICALLY)
            setConsumer(processor)
        }
        if (PermissionHelper.cameraPermissionsGranted(activity)) {
            startCamera()
        }
    }

    private fun startCamera() {
        cameraHelper = CameraXPreviewHelper().also { helper ->
            helper.setOnCameraStartedListener { surfaceTexture ->
                previewFrameTexture = surfaceTexture
                previewDisplayView.visibility = View.VISIBLE
            }
            helper.startCamera(activity, FlutterHandTrackingPlugin.CAMERA_FACING, null)
        }
    }

    override fun getView(): View = previewDisplayView
    override fun dispose() { converter?.close() }
}

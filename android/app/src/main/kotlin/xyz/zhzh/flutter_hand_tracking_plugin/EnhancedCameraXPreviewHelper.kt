// Copyright 2019 The MediaPipe Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.google.mediapipe.components

import android.app.Activity
import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata
import android.hardware.camera2.params.StreamConfigurationMap
import android.opengl.GLES20
import android.os.Handler
import android.os.HandlerThread
import android.os.Process
import android.os.SystemClock
import android.util.Log
import android.util.Size
import android.view.Surface
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.common.util.concurrent.ListenableFuture
import com.google.mediapipe.glutil.EglManager
import java.io.File
import java.util.concurrent.Executor
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException
import javax.microedition.khronos.egl.EGLSurface
import kotlin.math.abs

/**
 * Uses CameraX APIs for camera setup and access.
 *
 * [CameraX] connects to the camera and provides video frames.
 */
class EnhancedCameraXPreviewHelper : CameraHelper() {

    /** Listener invoked when the camera instance is available. */
    interface OnCameraBoundListener {
        /**
         * Called after CameraX has been bound to the lifecycle and the camera instance is available.
         */
        fun onCameraBound(camera: Camera)
    }

    /**
     * Provides an Executor that wraps a single-threaded Handler.
     *
     * All operations involving the surface texture should happen in a single thread, and that
     * thread should not be the main thread.
     *
     * The surface provider callbacks require an Executor, and the onFrameAvailable callback
     * requires a Handler. We want everything to run on the same thread, so we need an Executor that
     * is also a Handler.
     */
    private class SingleThreadHandlerExecutor(threadName: String, priority: Int) : Executor {
        private val handlerThread: HandlerThread = HandlerThread(threadName, priority).apply { start() }
        private val handler: Handler = Handler(handlerThread.looper)

        override fun execute(command: Runnable) {
            if (!handler.post(command)) {
                throw RejectedExecutionException("${handlerThread.name} is shutting down.")
            }
        }

        fun shutdown(): Boolean = handlerThread.quitSafely()
    }

    companion object {
        private const val TAG = "CameraXPreviewHelper"

        // Target frame and view resolution size in landscape.
        val TARGET_SIZE = Size(1280, 720)
        const val ASPECT_TOLERANCE = 0.25
        const val ASPECT_PENALTY = 10000.0

        // Number of attempts for calculating the offset between the camera's clock and MONOTONIC clock.
        const val CLOCK_OFFSET_CALIBRATION_ATTEMPTS = 3

        fun getCameraCharacteristics(
            context: Context,
            lensFacing: Int
        ): CameraCharacteristics? {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            return try {
                val cameraList = cameraManager.cameraIdList.toList()
                for (availableCameraId in cameraList) {
                    val availableCameraCharacteristics = cameraManager.getCameraCharacteristics(availableCameraId)
                    val availableLensFacing = availableCameraCharacteristics.get(CameraCharacteristics.LENS_FACING)
                        ?: continue

                    if (availableLensFacing == lensFacing) {
                        return availableCameraCharacteristics
                    }
                }
                null
            } catch (e: CameraAccessException) {
                Log.e(TAG, "Accessing camera ID info got error: $e")
                null
            }
        }
    }

    private val renderExecutor = SingleThreadHandlerExecutor("RenderThread", Process.THREAD_PRIORITY_DEFAULT)

    private var cameraProvider: ProcessCameraProvider? = null
    private var preview: Preview? = null
    private var imageCapture: ImageCapture? = null
    private var imageCaptureBuilder: ImageCapture.Builder? = null
    private var imageCaptureExecutorService: ExecutorService? = null
    private var camera: Camera? = null
    private var textures: IntArray? = null

    // Size of the camera-preview frames from the camera.
    private var frameSize: Size? = null

    // Rotation of the camera-preview frames in degrees.
    private var frameRotation: Int = 0

    // Checks if the image capture use case is enabled.
    private var isImageCaptureEnabled = false

    private var cameraCharacteristics: CameraCharacteristics? = null

    // Focal length resolved in pixels on the frame texture. If it cannot be determined, this value
    // is Float.MIN_VALUE.
    private var focalLengthPixels = Float.MIN_VALUE

    // Timestamp source of camera. This is retrieved from
    // CameraCharacteristics.SENSOR_INFO_TIMESTAMP_SOURCE. When CameraCharacteristics is not available
    // the source is CameraCharacteristics.SENSOR_INFO_TIMESTAMP_SOURCE_UNKNOWN.
    private var cameraTimestampSource = CameraCharacteristics.SENSOR_INFO_TIMESTAMP_SOURCE_UNKNOWN

    private var onCameraBoundListener: OnCameraBoundListener? = null

    private var isLandscapeOrientation = false

    /**
     * Initializes the camera and sets it up for accessing frames, using the default 1280 * 720
     * preview size.
     */
    override fun startCamera(
        activity: Activity,
        cameraFacing: CameraFacing,
        surfaceTexture: SurfaceTexture?
    ) {
        startCamera(activity, activity as LifecycleOwner, cameraFacing, surfaceTexture, TARGET_SIZE)
    }

    /**
     * Initializes the camera and sets it up for accessing frames.
     *
     * @param targetSize the preview size to use. If set to null, the helper will default to 1280 * 720.
     */
    fun startCamera(
        activity: Activity,
        cameraFacing: CameraFacing,
        surfaceTexture: SurfaceTexture?,
        targetSize: Size?
    ) {
        startCamera(activity, activity as LifecycleOwner, cameraFacing, surfaceTexture, targetSize)
    }

    /**
     * Initializes the camera and sets it up for accessing frames. This constructor also enables the
     * image capture use case from [CameraX].
     *
     * @param imageCaptureBuilder Builder for an [ImageCapture], this builder must contain the
     *     desired configuration options for the image capture being build (e.g. target resolution).
     * @param targetSize the preview size to use. If set to null, the helper will default to 1280 * 720.
     */
    fun startCamera(
        activity: Activity,
        imageCaptureBuilder: ImageCapture.Builder,
        cameraFacing: CameraFacing,
        targetSize: Size?
    ) {
        this.imageCaptureBuilder = imageCaptureBuilder
        startCamera(activity, activity as LifecycleOwner, cameraFacing, targetSize)
    }

    /**
     * Initializes the camera and sets it up for accessing frames. This constructor also enables the
     * image capture use case from [CameraX].
     *
     * @param imageCaptureBuilder Builder for an [ImageCapture], this builder must contain the
     *     desired configuration options for the image capture being build (e.g. target resolution).
     * @param targetSize the preview size to use. If set to null, the helper will default to 1280 * 720.
     */
    fun startCamera(
        activity: Activity,
        imageCaptureBuilder: ImageCapture.Builder,
        cameraFacing: CameraFacing,
        surfaceTexture: SurfaceTexture?,
        targetSize: Size?
    ) {
        this.imageCaptureBuilder = imageCaptureBuilder
        startCamera(activity, activity as LifecycleOwner, cameraFacing, surfaceTexture, targetSize)
    }

    /**
     * Initializes the camera and sets it up for accessing frames.
     *
     * @param targetSize a predefined constant [TARGET_SIZE]. If set to null, the
     *     helper will default to 1280 * 720.
     */
    fun startCamera(
        context: Context,
        lifecycleOwner: LifecycleOwner,
        cameraFacing: CameraFacing,
        targetSize: Size?
    ) {
        startCamera(context, lifecycleOwner, cameraFacing, null, targetSize)
    }

    /**
     * Initializes the camera and sets it up for accessing frames.
     *
     * @param targetSize a predefined constant [TARGET_SIZE]. If set to null, the
     *     helper will default to 1280 * 720.
     */
    fun startCamera(
        context: Context,
        lifecycleOwner: LifecycleOwner,
        cameraFacing: CameraFacing,
        surfaceTexture: SurfaceTexture?,
        targetSize: Size?
    ) {
        val mainThreadExecutor = ContextCompat.getMainExecutor(context)
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        val isSurfaceTextureProvided = surfaceTexture != null

        val selectedLensFacing = if (cameraFacing == CameraHelper.CameraFacing.FRONT) {
            CameraMetadata.LENS_FACING_FRONT
        } else {
            CameraMetadata.LENS_FACING_BACK
        }

        cameraCharacteristics = getCameraCharacteristics(context, selectedLensFacing)
        val resolvedTargetSize = getOptimalViewSize(targetSize) ?: TARGET_SIZE

        // According to CameraX documentation
        // (https://developer.android.com/training/camerax/configuration#specify-resolution):
        // "Express the resolution Size in the coordinate frame after rotating the supported sizes by
        // the target rotation."
        // Transpose width and height if using portrait orientation.
        val rotatedSize = if (isLandscapeOrientation) {
            Size(resolvedTargetSize.width, resolvedTargetSize.height)
        } else {
            Size(resolvedTargetSize.height, resolvedTargetSize.width)
        }

        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()
            } catch (e: Exception) {
                if (e is InterruptedException) {
                    Thread.currentThread().interrupt()
                }
                Log.e(TAG, "Unable to get ProcessCameraProvider: ", e)
                return@addListener
            }

            preview = Preview.Builder().setTargetResolution(rotatedSize).build()

            val cameraSelector = if (cameraFacing == CameraHelper.CameraFacing.FRONT) {
                CameraSelector.DEFAULT_FRONT_CAMERA
            } else {
                CameraSelector.DEFAULT_BACK_CAMERA
            }

            // Provide surface texture.
            preview?.setSurfaceProvider(renderExecutor) { request ->
                frameSize = request.resolution
                Log.d(
                    TAG,
                    "Received surface request for resolution ${frameSize?.width}x${frameSize?.height}"
                )

                val previewFrameTexture = if (isSurfaceTextureProvided) {
                    surfaceTexture!!
                } else {
                    createSurfaceTexture()
                }

                frameSize?.let { size ->
                    previewFrameTexture.setDefaultBufferSize(size.width, size.height)
                }

                request.setTransformationInfoListener(renderExecutor) { transformationInfo ->
                    frameRotation = transformationInfo.rotationDegrees
                    updateCameraCharacteristics()

                    if (!isSurfaceTextureProvided) {
                        // Detach the SurfaceTexture from the GL context we created earlier so that
                        // the MediaPipe pipeline can attach it.
                        // Only needed if MediaPipe pipeline doesn't provide a SurfaceTexture.
                        previewFrameTexture.detachFromGLContext()
                    }

                    onCameraStartedListener?.let { listener ->
                        ContextCompat.getMainExecutor(context).execute {
                            listener.onCameraStarted(previewFrameTexture)
                        }
                    }
                }

                val surface = Surface(previewFrameTexture)
                Log.d(TAG, "Providing surface")
                request.provideSurface(surface, renderExecutor) { result ->
                    Log.d(TAG, "Surface request result: $result")
                    textures?.let { textureArray ->
                        GLES20.glDeleteTextures(1, textureArray, 0)
                    }
                    // Per
                    // https://developer.android.com/reference/androidx/camera/core/SurfaceRequest.Result,
                    // the surface was either never used (RESULT_INVALID_SURFACE,
                    // RESULT_REQUEST_CANCELLED, RESULT_SURFACE_ALREADY_PROVIDED) or the surface
                    // was used successfully and was eventually detached
                    // (RESULT_SURFACE_USED_SUCCESSFULLY) so we can release it now to free up
                    // resources.
                    if (!isSurfaceTextureProvided) {
                        previewFrameTexture.release()
                    }
                    surface.release()
                }
            }

            // If we pause/resume the activity, we need to unbind the earlier preview use case, given
            // the way the activity is currently structured.
            cameraProvider?.unbindAll()

            // Bind use case(s) to camera.
            val boundCamera = imageCaptureBuilder?.let { builder ->
                imageCapture = builder.build()
                cameraProvider?.bindToLifecycle(lifecycleOwner, cameraSelector, preview!!, imageCapture!!)?.also {
                    imageCaptureExecutorService = Executors.newSingleThreadExecutor()
                    isImageCaptureEnabled = true
                }
            } ?: run {
                cameraProvider?.bindToLifecycle(lifecycleOwner, cameraSelector, preview!!)
            }

            camera = boundCamera
            onCameraBoundListener?.let { listener ->
                ContextCompat.getMainExecutor(context).execute {
                    boundCamera?.let { listener.onCameraBound(it) }
                }
            }
        }, mainThreadExecutor)
    }

    /**
     * Stops the camera and releases all associated resources.
     *
     * This method should be called when the camera is no longer needed to properly
     * clean up resources and prevent memory leaks.
     */
    fun stopCamera() {
        try {
            // Unbind all use cases from the camera
            cameraProvider?.unbindAll()

            // Clear camera reference
            camera = null

            // Clean up preview
            preview = null

            // Clean up image capture resources
            imageCapture = null
            imageCaptureBuilder = null

            // Shutdown image capture executor service
            imageCaptureExecutorService?.let { executor ->
                executor.shutdown()
                try {
                    if (!executor.awaitTermination(1000, java.util.concurrent.TimeUnit.MILLISECONDS)) {
                        executor.shutdownNow()
                    }
                } catch (e: InterruptedException) {
                    executor.shutdownNow()
                    Thread.currentThread().interrupt()
                }
            }
            imageCaptureExecutorService = null

            // Clean up OpenGL textures if they exist
            textures?.let { textureArray ->
                GLES20.glDeleteTextures(1, textureArray, 0)
                textures = null
            }

            // Shutdown render executor
            renderExecutor.shutdown()

            // Clear camera provider reference
            cameraProvider = null

            // Reset camera characteristics and related fields
            cameraCharacteristics = null
            frameSize = null
            frameRotation = 0
            focalLengthPixels = Float.MIN_VALUE
            cameraTimestampSource = CameraCharacteristics.SENSOR_INFO_TIMESTAMP_SOURCE_UNKNOWN
            isImageCaptureEnabled = false

            // Clear listeners
            onCameraBoundListener = null

            Log.d(TAG, "Camera resources released successfully")

        } catch (e: Exception) {
            Log.e(TAG, "Error while stopping camera: ", e)
        }
    }

    /**
     * Captures a new still image and saves to a file along with application specified metadata. This
     * method works when [CameraXPreviewHelper.startCamera] with [ImageCapture.Builder]
     * has been called previously enabling image capture. The callback will be
     * called only once for every invocation of this method.
     *
     * @param outputFile Save location for captured image.
     * @param onImageSavedCallback Callback to be called for the newly captured image.
     */
    fun takePicture(outputFile: File, onImageSavedCallback: ImageCapture.OnImageSavedCallback) {
        imageCaptureExecutorService?.let { executor ->
            takePicture(outputFile, onImageSavedCallback, executor)
        }
    }

    /**
     * Captures a new still image and saves to a file along with application specified metadata. This
     * method works when [CameraXPreviewHelper.startCamera] with [ImageCapture.Builder]
     * has been called previously enabling image capture. The callback will be
     * called only once for every invocation of this method.
     *
     * @param outputFile Save location for captured image.
     * @param onImageSavedCallback Callback to be called for the newly captured image.
     * @param executorService Executor service to handle image capture.
     */
    fun takePicture(
        outputFile: File,
        onImageSavedCallback: ImageCapture.OnImageSavedCallback,
        executorService: ExecutorService
    ) {
        if (isImageCaptureEnabled) {
            val outputFileOptions = ImageCapture.OutputFileOptions.Builder(outputFile).build()
            imageCapture?.takePicture(outputFileOptions, executorService, onImageSavedCallback)
        }
    }

    override fun isCameraRotated(): Boolean = frameRotation % 180 == 90

    override fun computeDisplaySizeFromViewSize(viewSize: Size): Size? {
        // Camera target size is computed already, so just return the capture frame size.
        return frameSize
    }

    private fun getOptimalViewSize(targetSize: Size?): Size? {
        if (targetSize == null || cameraCharacteristics == null) {
            return null
        }

        val map = cameraCharacteristics?.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
        val outputSizes = map?.getOutputSizes(SurfaceTexture::class.java) ?: return null

        // Find the best matching size. We give a large penalty to sizes whose aspect
        // ratio is too different from the desired one. That way we choose a size with
        // an acceptable aspect ratio if available, otherwise we fall back to one that
        // is close in width.
        var optimalSize: Size? = null
        val targetRatio = targetSize.width.toDouble() / targetSize.height
        Log.d(TAG, "Camera target size ratio: $targetRatio width: ${targetSize.width}")

        var minCost = Double.MAX_VALUE
        for (size in outputSizes) {
            val aspectRatio = size.width.toDouble() / size.height
            val ratioDiff = abs(aspectRatio - targetRatio)
            val cost = (if (ratioDiff > ASPECT_TOLERANCE) {
                ASPECT_PENALTY + ratioDiff * targetSize.height
            } else {
                0.0
            }) + abs(size.width - targetSize.width)

            Log.d(
                TAG,
                "Camera size candidate width: ${size.width} height: ${size.height} ratio: $aspectRatio cost: $cost"
            )

            if (cost < minCost) {
                optimalSize = size
                minCost = cost
            }
        }

        optimalSize?.let { size ->
            Log.d(TAG, "Optimal camera size width: ${size.width} height: ${size.height}")
        }

        return optimalSize
    }

    // Computes the difference between the camera's clock and MONOTONIC clock using camera's
    // timestamp source information. This function assumes by default that the camera timestamp
    // source is aligned to CLOCK_MONOTONIC. This is useful when the camera is being used
    // synchronously with other sensors that yield timestamps in the MONOTONIC timebase, such as
    // AudioRecord for audio data. The offset is returned in nanoseconds.
    fun getTimeOffsetToMonoClockNanos(): Long {
        return if (cameraTimestampSource == CameraMetadata.SENSOR_INFO_TIMESTAMP_SOURCE_REALTIME) {
            // This clock shares the same timebase as SystemClock.elapsedRealtimeNanos(), see
            // https://developer.android.com/reference/android/hardware/camera2/CameraMetadata.html#SENSOR_INFO_TIMESTAMP_SOURCE_REALTIME.
            getOffsetFromRealtimeTimestampSource()
        } else {
            getOffsetFromUnknownTimestampSource()
        }
    }

    private fun getOffsetFromUnknownTimestampSource(): Long {
        // Implementation-wise, this timestamp source has the same timebase as CLOCK_MONOTONIC, see
        // https://stackoverflow.com/questions/38585761/what-is-the-timebase-of-the-timestamp-of-cameradevice.
        return 0L
    }

    private fun getOffsetFromRealtimeTimestampSource(): Long {
        // Measure the offset of the REALTIME clock w.r.t. the MONOTONIC clock. Do
        // CLOCK_OFFSET_CALIBRATION_ATTEMPTS measurements and choose the offset computed with the
        // smallest delay between measurements. When the camera returns a timestamp ts, the
        // timestamp in MONOTONIC timebase will now be (ts + cameraTimeOffsetToMonoClock).
        var offset = Long.MAX_VALUE
        var lowestGap = Long.MAX_VALUE

        repeat(CLOCK_OFFSET_CALIBRATION_ATTEMPTS) {
            val startMonoTs = System.nanoTime()
            val realTs = SystemClock.elapsedRealtimeNanos()
            val endMonoTs = System.nanoTime()
            val gapMonoTs = endMonoTs - startMonoTs

            if (gapMonoTs < lowestGap) {
                lowestGap = gapMonoTs
                offset = (startMonoTs + endMonoTs) / 2 - realTs
            }
        }
        return offset
    }

    fun getFocalLengthPixels(): Float = focalLengthPixels

    fun getFrameSize(): Size? = frameSize

    /**
     * Sets whether the device is in landscape orientation.
     *
     * Must be called before [startCamera]. Portrait orientation is assumed by default.
     */
    fun setLandscapeOrientation(landscapeOrientation: Boolean) {
        isLandscapeOrientation = landscapeOrientation
    }

    /**
     * Sets a listener that will be invoked when CameraX is bound.
     *
     * The listener will be invoked on the main thread after the next call to [startCamera].
     * The [Camera] instance can be used to get camera info and control the camera (e.g. zoom level).
     */
    fun setOnCameraBoundListener(listener: OnCameraBoundListener?) {
        onCameraBoundListener = listener
    }

    private fun updateCameraCharacteristics() {
        cameraCharacteristics?.let { characteristics ->
            // Queries camera timestamp source. It should be one of REALTIME or UNKNOWN
            // as documented in
            // https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics.html#SENSOR_INFO_TIMESTAMP_SOURCE.
            cameraTimestampSource = characteristics.get(CameraCharacteristics.SENSOR_INFO_TIMESTAMP_SOURCE)
                ?: CameraCharacteristics.SENSOR_INFO_TIMESTAMP_SOURCE_UNKNOWN
            focalLengthPixels = calculateFocalLengthInPixels()
        }
    }

    // Computes the focal length of the camera in pixels based on lens and sensor properties.
    private fun calculateFocalLengthInPixels(): Float {
        val characteristics = cameraCharacteristics ?: return Float.MIN_VALUE
        val currentFrameSize = frameSize ?: return Float.MIN_VALUE

        // Focal length of the camera in millimeters.
        // Note that CameraCharacteristics returns a list of focal lengths and there could be more
        // than one focal length available if optical zoom is enabled or there are multiple physical
        // cameras in the logical camera referenced here. A theoretically correct way of doing this would
        // be to use the focal length set explicitly via Camera2 API, as documented in
        // https://developer.android.com/reference/android/hardware/camera2/CaptureRequest#LENS_FOCAL_LENGTH.
        val focalLengthMm = characteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)?.get(0)
            ?: return Float.MIN_VALUE

        // Sensor Width of the camera in millimeters.
        val sensorWidthMm = characteristics.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)?.width
            ?: return Float.MIN_VALUE

        return currentFrameSize.width * focalLengthMm / sensorWidthMm
    }

    private fun createSurfaceTexture(): SurfaceTexture {
        // Create a temporary surface to make the context current.
        val eglManager = EglManager(null)
        val tempEglSurface = eglManager.createOffscreenSurface(1, 1)
        eglManager.makeCurrent(tempEglSurface, tempEglSurface)
        textures = IntArray(1)
        GLES20.glGenTextures(1, textures, 0)
        return SurfaceTexture(textures!![0])
    }
}
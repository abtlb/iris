package xyz.zhzh.flutter_hand_tracking_plugin

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class HandTrackingViewFactory(
    private val activity: Activity,
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        id: Int,
        args: Any?
    ): PlatformView {
        return HandTrackingPlatformView(
            activity,
            messenger,
            id
        )
    }
}

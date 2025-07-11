# MediaPipe Core
-keep class com.google.mediapipe.** { *; }
-keep interface com.google.mediapipe.** { *; }
-keep enum com.google.mediapipe.** { *; }
-keep class mediapipe.** { *; }
-keep interface mediapipe.** { *; }
-keep enum mediapipe.** { *; }

# MediaPipe Components
-keep class com.google.mediapipe.components.** { *; }
-keep class com.google.mediapipe.framework.** { *; }
-keep class com.google.mediapipe.glutil.** { *; }

# Your custom plugin
-keep class xyz.zhzh.flutter_hand_tracking_plugin.** { *; }

# CameraX
-keep class androidx.camera.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class androidx.concurrent.** { *; }

# Google Play Core (FIX for your R8 error)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store Integration
#-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Protocol Buffers
-keep class com.google.protobuf.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }

# JNI and native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all packet-related methods
-keepclassmembers class * {
    public void addPacketCallback(...);
    public void removePacketCallback(...);
}

# Static initializers
-keepclassmembers class * {
    static <clinit>();
}

# Flutter platform channels
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# General Android components
-keep class androidx.** { *; }
-dontwarn androidx.**

# Don't warn about missing classes
-dontwarn com.google.mediapipe.**
-dontwarn mediapipe.**
-dontwarn com.google.protobuf.**
-dontwarn org.tensorflow.lite.**
-dontwarn androidx.camera.**
-dontwarn xyz.zhzh.flutter_hand_tracking_plugin.**
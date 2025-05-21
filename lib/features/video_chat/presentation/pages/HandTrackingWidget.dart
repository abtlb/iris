import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/protobuf.dart';             // for decoding

import 'package:untitled3/protos/landmark.pb.dart';

import '../../data/others/asl_detector.dart';                   // if you generated Dart protobufs

class HandTrackingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'plugins.zhzh.xyz/flutter_hand_tracking_plugin/view',
      surfaceFactory: (context, controller) =>
          AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const {},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
      onCreatePlatformView: (params) {
        final view = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: 'plugins.zhzh.xyz/flutter_hand_tracking_plugin/view',
          layoutDirection: TextDirection.ltr,
        )
        // **wait until the platform view is actually created**
          ..addOnPlatformViewCreatedListener((id) {
            // tell Flutter the view is ready
            params.onPlatformViewCreated(id);

            // now the native side has done its init and setStreamHandler,
            // so it's safe to subscribe to the EventChannel:
            EventChannel(
              'plugins.zhzh.xyz/flutter_hand_tracking_plugin/$id/landmarks',
            ).receiveBroadcastStream().listen((dynamic rawBytes) {
              try {
                final list = NormalizedLandmarkList.fromBuffer(rawBytes);
                GetIt.instance<ASLDetector>().predictFromLandmarks(list.landmark);
                print("Decoded landmarks: ${list.landmark.length}");
              } catch (e) {
                print("FAILED TO PARSE: $e");
              }
            }, onError: (e) {
              print("Stream error: $e");
            });
          });

        view.create();
        return view;
      },
    );
  }
}

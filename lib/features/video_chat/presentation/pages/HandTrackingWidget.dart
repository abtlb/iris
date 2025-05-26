import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/protobuf.dart';

import 'package:untitled3/protos/landmark.pb.dart';
import '../../data/others/asl_detector.dart';

class HandTrackingManager {
  static HandTrackingManager? _instance;
  static HandTrackingManager get instance => _instance ??= HandTrackingManager._();

  HandTrackingManager._();

  AndroidViewController? _controller;
  EventChannel? _eventChannel;
  bool _isInitialized = false;
  bool _isDisposed = false;

  Future<AndroidViewController?> getController() async {
    if (_isDisposed) return null;

    if (_controller != null && _isInitialized) {
      return _controller;
    }

    // Dispose existing controller first
    await dispose();

    return null; // Let the widget create a new one
  }

  void setController(AndroidViewController controller, int viewId) {
    _controller = controller;
    _setupEventChannel(viewId);
  }

  void _setupEventChannel(int viewId) {
    if (_eventChannel != null || _isDisposed) return;

    _eventChannel = EventChannel(
      'plugins.zhzh.xyz/flutter_hand_tracking_plugin/$viewId/landmarks',
    );

    _eventChannel!.receiveBroadcastStream().listen((dynamic rawBytes) {
      if (_isDisposed) return;

      try {
        final list = NormalizedLandmarkList.fromBuffer(rawBytes);
        GetIt.instance<ASLDetector>().predictFromLandmarks(list.landmark);
      } catch (e) {
        print("FAILED TO PARSE: $e");
      }
    }, onError: (e) {
      print("Stream error: $e");
    });

    _isInitialized = true;
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _isInitialized = false;

    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    _eventChannel = null;
  }

  void reset() {
    _isDisposed = false;
  }
}

class HandTrackingWidget extends StatefulWidget {
  @override
  _HandTrackingWidgetState createState() => _HandTrackingWidgetState();
}

class _HandTrackingWidgetState extends State<HandTrackingWidget>
    with AutomaticKeepAliveClientMixin {

  final HandTrackingManager _manager = HandTrackingManager.instance;
  bool _isCreating = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _manager.reset(); // Reset disposed state when widget is recreated
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PlatformViewLink(
      viewType: 'plugins.zhzh.xyz/flutter_hand_tracking_plugin/view',
      surfaceFactory: (context, controller) =>
          AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const {},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
      onCreatePlatformView: (params) {
        return _createPlatformView(params);
      },
    );
  }

  AndroidViewController _createPlatformView(PlatformViewCreationParams params) {
    // Check if we already have a controller (simplified approach)
    if (_manager._controller != null && _manager._isInitialized) {
      params.onPlatformViewCreated(params.id);
      return _manager._controller!;
    }

    _isCreating = true;

    final view = PlatformViewsService.initSurfaceAndroidView(
      id: params.id,
      viewType: 'plugins.zhzh.xyz/flutter_hand_tracking_plugin/view',
      layoutDirection: TextDirection.ltr,
    );

    view.addOnPlatformViewCreatedListener((id) {
      params.onPlatformViewCreated(id);

      // Set up the manager with this controller
      _manager.setController(view, id);
      _isCreating = false;
    });

    view.create();

    return view;
  }

  @override
  void dispose() {
    // Don't dispose the manager here - let it persist
    super.dispose();
  }
}

// Alternative: Simpler approach with static tracking
class SimpleHandTrackingWidget extends StatefulWidget {
  @override
  _SimpleHandTrackingWidgetState createState() => _SimpleHandTrackingWidgetState();
}

class _SimpleHandTrackingWidgetState extends State<SimpleHandTrackingWidget> {
  static bool _isCreated = false;
  static int? _activeViewId;

  @override
  Widget build(BuildContext context) {
    // Prevent multiple instances
    if (_isCreated) {
      return Container(
        child: Text('Hand tracking already active'),
      );
    }

    return PlatformViewLink(
      viewType: 'plugins.zhzh.xyz/flutter_hand_tracking_plugin/view',
      surfaceFactory: (context, controller) =>
          AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const {},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
      onCreatePlatformView: (params) {
        if (_isCreated && _activeViewId == params.id) {
          // Return existing view somehow - this is tricky with PlatformViewLink
          // Better to use the manager approach above
        }

        final view = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: 'plugins.zhzh.xyz/flutter_hand_tracking_plugin/view',
          layoutDirection: TextDirection.ltr,
        );

        view.addOnPlatformViewCreatedListener((id) {
          if (_isCreated) {
            // Another instance was already created, dispose this one
            view.dispose();
            return;
          }

          _isCreated = true;
          _activeViewId = id;
          params.onPlatformViewCreated(id);

          EventChannel(
            'plugins.zhzh.xyz/flutter_hand_tracking_plugin/$id/landmarks',
          ).receiveBroadcastStream().listen((dynamic rawBytes) {
            try {
              final list = NormalizedLandmarkList.fromBuffer(rawBytes);
              GetIt.instance<ASLDetector>().predictFromLandmarks(list.landmark);
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

  @override
  void dispose() {
    _isCreated = false;
    _activeViewId = null;
    super.dispose();
  }
}
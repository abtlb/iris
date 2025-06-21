import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/video_chat/data/repository/AgoraVideoChatRepository.dart';
import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';
import 'package:untitled3/features/video_chat/domain/usecases/getPredictionStream.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_events.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_states.dart';
import 'package:untitled3/core/util/app_route.dart';
import '../../../chat/domain/entities/message.dart';
import '../../../chat/domain/usecases/chat_usecase.dart';
import '../../data/others/asl_detector.dart';
import '../../services/ speech_to_text_service.dart';
import '../bloc/remote_bloc/remote_states.dart';
import '../widgets/FloatingHandTracking.dart';
import '../widgets/LocalVideoWidget.dart';
import '../widgets/RemoteVideoWidget.dart';
import '../../domain/utils/channel_name_generator.dart';

class VideoChatTestPage extends StatefulWidget {
  final String username1;
  final String username2;

  const VideoChatTestPage({super.key, required this.username1, required this.username2});

  @override
  State<VideoChatTestPage> createState() => _VideoChatTestPageState();
}

class _VideoChatTestPageState extends State<VideoChatTestPage> {
  ChatUseCase chatUseCase = GetIt.instance<ChatUseCase>();
  //todo remove
  VideoChatRepository agoraVideoChatRepository = GetIt.instance<VideoChatRepository>();

  @override
  void initState() {
    super.initState();
    context.read<VideoChatBloc>().add(VideoChatConnectionRequested(
      channelName: ChannelNameGenerator.makeChannelName(widget.username1, widget.username2),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("ASL Video Call")),
        body: BlocConsumer<VideoChatBloc, VideoChatState>(
            listener: (context, state) {
              if (state is VideoChatConnectionFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Connection failed: ${state.exception}")),
                );
              } else if (state is VideoChatDisconnected) {
                context.go(AppRoute.chatHomePath);
              }
            },
            builder: (context, state) {
              if (state is VideoChatInitial || state is VideoChatConnecting) {
                return const Center(child: CircularProgressIndicator());
              }

              RtcEngine? engine;
              int? remoteUid;

              if (state is VideoChatShowRemoteUser) {
                engine = state.engine;
                remoteUid = 0;
              } else if (state is VideoChatConnected) {
                engine = state.engine;
              }


              return Stack(
                children: [
                  // Remote video (if available)
                  // if (remoteUid != null)
                  //   RemoteVideoWidget(
                  //     engine: engine!,
                  //     remoteUid: remoteUid!,
                  //     channel: ChannelNameGenerator.makeChannelName(widget.username1, widget.username2),
                  //   ),
                  //
                  // // Local video preview
                  // Positioned(
                  //   top: 20,
                  //   right: 20,
                  //   width: 120,
                  //   height: 160,
                  //   child: LocalVideoWidget(engine: engine!),
                  // ),


                  // End call button
                  // Positioned(
                  //   bottom: 20,
                  //   left: 0,
                  //   right: 0,
                  //   child: Center(
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.red,
                  //         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  //       ),
                  //       onPressed: () => context.read<VideoChatBloc>().add(VideoChatDisconnectRequested()),
                  //       child: const Text("END CALL", style: TextStyle(color: Colors.white)),
                  //     ),
                  //   ),
                  // ),
                  // Positioned(
                  //   bottom: 20,
                  //   left: 0,
                  //   right: 0,
                  //   child: Center(
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.red,
                  //         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  //       ),
                  //       onPressed: () async {
                  //         await agoraVideoChatRepository.disableAudio();
                  //         SpeechToTextService speechToTextService = SpeechToTextService();
                  //         await speechToTextService.initialize();
                  //         speechToTextService.startListening((result) => print(result));
                  //       },
                  //       child: const Text("TEST SPEECH", style: TextStyle(color: Colors.white)),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
        ),
      );
      }
}

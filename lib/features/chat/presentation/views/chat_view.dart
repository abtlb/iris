import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/chatView_body.dart';

import '../../../../core/util/app_route.dart';
import '../../../video_chat/presentation/bloc/connection_bloc/video_chat_bloc.dart';
import '../../../video_chat/presentation/bloc/local_bloc/local_bloc.dart';
import '../../../video_chat/presentation/bloc/remote_bloc/remote_bloc.dart';
import '../blocs/chat_bloc.dart';
import '../blocs/voice/voice_bloc.dart';

class ChatView extends StatelessWidget {
  final String senderId;
  final String receiverId;
  const ChatView({super.key, required this.senderId, required this.receiverId});

  @override
  Widget build(BuildContext context) {
    return
      MultiBlocProvider(
        providers: [
          //video bloc is already provided
          BlocProvider<LocalVideoBloc>(
            create: (_) => GetIt.instance<LocalVideoBloc>(),
          ),
          BlocProvider<RemoteVideoBloc>(
            create: (_) => GetIt.instance<RemoteVideoBloc>(),
          ),
          BlocProvider<VoiceBloc>(
            create: (_) => GetIt.instance<VoiceBloc>(),
          ),
          BlocProvider<ChatBloc>(
              create: (_) => GetIt.instance<ChatBloc>()
          ),
          BlocProvider<VideoChatBloc>(
              create: (_) => GetIt.instance<VideoChatBloc>()
          ),
        ],
        child:
      PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          GoRouter.of(context).push(AppRoute.chatHomePath);
        }
      },
      child: Scaffold(
        body: ChatviewBody(senderId: senderId, receiverId: receiverId,),
      )
      )
      );
  }
}

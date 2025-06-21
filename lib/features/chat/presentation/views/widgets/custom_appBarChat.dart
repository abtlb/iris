import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/styles.dart';
import 'package:untitled3/core/util/widgets/custom_iconButton.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/video_chat/presentation/widgets/HandTrackingWidget.dart';

import '../../../../video_chat/domain/utils/channel_name_generator.dart';
import '../../../../video_chat/presentation/bloc/connection_bloc/video_chat_bloc.dart';
import '../../../../video_chat/presentation/bloc/connection_bloc/video_chat_events.dart';

class CustomAppbarChat extends StatelessWidget {
  const CustomAppbarChat({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context) {
    return
      // SafeArea( child:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                context.read<VideoChatBloc>().add(VideoChatDisconnectRequested());
                //todo remove this and make it not async
                await HandTrackingManager.instance.dispose();
                GoRouter.of(context).push(AppRoute.chatHomePath);
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: Styles.textStyle30.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontFamily: kFont,
                ),
              ),
            ),
          ],
        ),
      // ),
    );
  }
}

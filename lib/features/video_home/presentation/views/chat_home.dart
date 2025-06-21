import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/video_home/presentation/manager/select_category_cubit/select_category_cubit.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/custom_drawer.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/homView_body.dart';

class ChatHome extends StatelessWidget {
  const ChatHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectCategoryCubit(),
      child: const Scaffold(
        backgroundColor: kBackgroundColor,
        body: HomeviewBody(),
      ),
    );
  }
}

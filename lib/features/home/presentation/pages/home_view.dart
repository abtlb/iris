import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/home/presentation/bloc/home/home_cubit.dart';
import 'package:untitled3/features/video_home/presentation/manager/select_category_cubit/select_category_cubit.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/custom_drawer.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/homView_body.dart';

import 'home_page .dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        endDrawer: const Drawer(
          backgroundColor: kPrimaryColor,
          child: CustomDrawer(),
        ),
        body: HomePage(),
      ),
    );
  }


}

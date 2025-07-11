// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'dart:math';
// import 'package:go_router/go_router.dart';
// import 'package:untitled3/core/constants/constants.dart';
// import 'package:untitled3/core/storage/storage.dart';
// import 'package:untitled3/core/util/app_route.dart';
// import 'package:untitled3/features/auth/domain/usecases/get_current_user.dart';
// import 'package:untitled3/features/auth/domain/usecases/get_user.dart';
//
// import '../../../../core/util/widgets/custom_iconButton.dart';
//
// class HomePage extends StatefulWidget {
//   HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final List<Map<String, dynamic>> icons = [
//     {'icon': Icons.school, 'label': 'Learning', 'route': AppRoute.learningStart},
//     {'icon': Icons.zoom_in, 'label': 'Magnify', 'route': AppRoute.magnifierPath},
//     {'icon': Icons.hearing, 'label': 'Sound Detection', 'route': AppRoute.soundDetection},
//     {'icon': Icons.chat, 'label': 'Chat', 'route': AppRoute.chatHomePath},
//     {'icon': Icons.alarm, 'label': 'Alarm', 'route': AppRoute.alarmPath},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double radius = 150;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               kBackgroundColor,
//               kPrimaryColor
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               Positioned(
//                 top: 30,
//                 right: 10,
//                 child: CustomIconButton(
//                   icon: Icons.account_circle_rounded,
//                   color: kSecondaryColor,
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               ),
//               Column(
//                 children: [
//                   const SizedBox(height: 60),
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.yellow.withOpacity(0.6),
//                           blurRadius: 40,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 70),
//                   Center(
//                     child: Text(
//                       "Welcome, ya ebn el mara el sharmota!",
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontWeight: FontWeight.bold,
//                         color: kTextPrimary,
//                         fontFamily: kFont
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 30),
//                     child: Text(
//                       "Select a service to explore",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 20, color: Colors.black54, fontFamily: kFont),
//                     ),
//                   ),
//                 ],
//               ),
//               Builder(
//                 builder: (context) {
//                   final Size size = MediaQuery.of(context).size;
//                   final double centerX = size.width / 2;
//                   final double centerY = size.height / 2 + 30;
//
//                   return Stack(
//                     children: List.generate(icons.length, (index) {
//                       final angle = (2 * pi / icons.length) * index + 0.95;
//                       final offset = Offset(
//                         radius * cos(angle),
//                         radius * sin(angle),
//                       );
//
//                       return Positioned(
//                         left: centerX + offset.dx - 45,
//                         top: centerY + offset.dy - 45,
//                         child: GestureDetector(
//                           onTap: () {
//                             context.push(icons[index]['route']);
//                           },
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               CircleAvatar(
//                                 radius: 45,
//                                 backgroundColor: kPrimaryColor,
//                                 child: Icon(
//                                   icons[index]['icon'],
//                                   color: Colors.white,
//                                   size: 35,
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 icons[index]['label'],
//                                 style:  TextStyle(
//                                   fontSize: 15,
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.w500,
//                                     fontFamily: kFont
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/storage/storage.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/auth/domain/usecases/get_current_user.dart';
import 'package:untitled3/features/auth/domain/usecases/get_user.dart';

import '../../../../core/util/widgets/custom_iconButton.dart';
import '../../../home/presentation/bloc/home/home_cubit.dart';
import '../../../home/presentation/bloc/home/home_state.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> icons = [
    {'icon': Icons.school, 'label': 'Sign Learn', 'route': AppRoute.learningHome},
    {'icon': Icons.zoom_in, 'label': 'Glass Magnifier', 'route': AppRoute.magnifierPath},
    {'icon': Icons.hearing, 'label': 'Sound Guard', 'route': AppRoute.soundDetection},
    {'icon': Icons.chat, 'label': 'Universal Chat', 'route': AppRoute.chatHomePath},
    {'icon': Icons.alarm, 'label': 'Pulse Alarm', 'route': AppRoute.alarmPath},
  ];

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadFirstName();
  }

  @override
  Widget build(BuildContext context) {
    double radius = 150;

    return BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is !HomeLoaded) {
              return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kBackgroundColor,
                        kPrimaryColor
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator())
              );
            }
            return Scaffold(
              body:

              Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kBackgroundColor,
                    kPrimaryColor
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 30,
                      right: 10,
                      child: CustomIconButton(
                        icon: Icons.account_circle_rounded,
                        color: kSecondaryColor,
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.6),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 70),
                        Center(
                          child: Text(
                            "Welcome, ${state.firstName}!",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: kTextPrimary,
                                fontFamily: kFont
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Select a service to explore",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: Colors.black54, fontFamily: kFont),
                          ),
                        ),
                      ],
                    ),
                    Builder(
                      builder: (context) {
                        final Size size = MediaQuery.of(context).size;
                        final double centerX = size.width / 2;
                        final double centerY = size.height / 2 + 30;

                        return Stack(
                          children: List.generate(icons.length, (index) {
                            final angle = (2 * pi / icons.length) * index + 0.95;
                            final offset = Offset(
                              radius * cos(angle),
                              radius * sin(angle),
                            );

                            return Positioned(
                              left: centerX + offset.dx - 45,
                              top: centerY + offset.dy - 45,
                              child: GestureDetector(
                                onTap: () {
                                  context.push(icons[index]['route']);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 45,
                                      backgroundColor: kPrimaryColor,
                                      child: Icon(
                                        icons[index]['icon'],
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      icons[index]['label'],
                                      style:  TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: kFont
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
              )
            );
          },
    );
  }
}
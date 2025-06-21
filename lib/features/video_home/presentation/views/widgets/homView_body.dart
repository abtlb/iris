import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/video_home/presentation/manager/select_category_cubit/select_category_cubit.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/calls_listview.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/custom_appBar.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/custom_categories.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/messages_listView.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/show_stories_listview.dart';

import '../../../../../core/util/app_route.dart';
import '../../../../../core/util/styles.dart';
import 'custom_category.dart';

class HomeviewBody extends StatelessWidget {
  const HomeviewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, kBackgroundColor],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with gradient background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 50, left: 30, right: 30, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // BACK BUTTON with white color for better contrast
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: kTextLight),
                                onPressed: () {
                                  context.go('/main');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // TITLE with light color
                            Text(
                              'Chat with\nfriends',
                              style: Styles.textStyle30.copyWith(
                                color: kTextLight,
                                fontWeight: FontWeight.bold,
                                fontFamily: kFont,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: CustomCategory(
                      onTap: () {
                        GoRouter.of(context).push(AppRoute.kSearchPath);
                      },
                      iconData: Icons.search,
                      title: "Search",
                      backgroundColor: Colors.transparent,
                      textColor: kTextLight,
                      width: MediaQuery.of(context).size.width * 0.95,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.1),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, -5),
                      //   ),
                      // ],
                    ),
                    child: BlocBuilder<SelectCategoryCubit, SelectCategoryState>(
                      builder: (context, state) {
                        return const MessagesListview(notify: 0);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
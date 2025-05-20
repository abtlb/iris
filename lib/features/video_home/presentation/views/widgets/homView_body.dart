import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/video_home/presentation/manager/select_category_cubit/select_category_cubit.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/calls_listview.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/custom_appBar.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/custom_categories.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/messages_listView.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/show_stories_listview.dart';

class HomeviewBody extends StatelessWidget {
  const HomeviewBody({super.key});

  @override
  Widget build(BuildContext context) {
    // whole-screen background color
    const background = KBGColor;

    return Container(
      color: background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        slivers: [
          const SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(),
                ShowStoriesListview(),
                //CustomCategories(),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                      // bottom-panel background color
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: BlocBuilder<SelectCategoryCubit, SelectCategoryState>(
                      builder: (context, state) {
                        if (state is CategoriesIndex1) {
                          return const MessagesListview(notify: 0);
                        } else if (state is CategoriesIndex2) {
                          return const MessagesListview(notify: 6);
                        } else if (state is CategoriesIndex3) {
                          return const CallsListview();
                        } else {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height,
                          );
                        }
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

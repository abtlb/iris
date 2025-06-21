import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // ✅ For navigation
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/video_home/presentation/manager/select_category_cubit/select_category_cubit.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/custom_category.dart';
import 'package:untitled3/core/util/app_route.dart'; // ✅ Your AppRoute file


class CustomCategories extends StatelessWidget {
  const CustomCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: BlocBuilder<SelectCategoryCubit, SelectCategoryState>(
        builder: (context, state) {
          return SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CustomCategory(
                  title: 'Coversations',
                  width: 120,
                  backgroundColor: state is CategoriesIndex1 ? kContainerColor : kPrimaryColor,
                  textColor: state is CategoriesIndex1 ? Colors.white : Colors.grey,
                  onTap: () {
                    context.read<SelectCategoryCubit>().selectCategory(1);
                  },
                ),

                CustomCategory(
                  width: 90,
                  title: 'Unread',
                  textColor: state is CategoriesIndex2 ? Colors.white : Colors.grey,
                  backgroundColor: state is CategoriesIndex2 ? kContainerColor : kPrimaryColor,
                  onTap: () {
                    context.read<SelectCategoryCubit>().selectCategory(2);
                  },
                ),
                CustomCategory(
                  width: 70,
                  title: 'Calls',
                  textColor: state is CategoriesIndex3 ? Colors.white : Colors.grey,
                  backgroundColor: state is CategoriesIndex3 ? kContainerColor : kPrimaryColor,
                  onTap: () {
                    context.read<SelectCategoryCubit>().selectCategory(3);
                  },
                ),
                CustomCategory(
                  width: 100,
                  title: 'Learning',
                  textColor: state is CategoriesIndex4 ? Colors.white : Colors.grey,
                  backgroundColor: state is CategoriesIndex4 ? kContainerColor : kPrimaryColor,
                  onTap: () {
                    context.read<SelectCategoryCubit>().selectCategory(4);
                  },
                ),
                CustomCategory(
                  width: 110,
                  title: 'Magnifier',
                  textColor: state is CategoriesIndex5 ? Colors.white : Colors.grey,
                  backgroundColor: state is CategoriesIndex5 ? kContainerColor : kPrimaryColor,
                  onTap: () {
                    context.read<SelectCategoryCubit>().selectCategory(5);
                    context.push(AppRoute.magnifierPath); // ✅ Navigate to Magnifier screen
                  },
                ),

                CustomCategory(
                  width: 110,
                  title: 'Alarm',
                  textColor: state is CategoriesIndex6 ? Colors.white : Colors.grey,
                  backgroundColor: state is CategoriesIndex6 ? kContainerColor : kPrimaryColor,
                  onTap: () {
                    context.read<SelectCategoryCubit>().selectCategory(5);
                    context.push(AppRoute.alarmPath);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

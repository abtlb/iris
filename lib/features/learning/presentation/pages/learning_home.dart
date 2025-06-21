import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/learning/presentation/pages/learning_start_screen.dart';
import 'package:untitled3/features/learning/domain/entities/course.dart';
import 'package:untitled3/features/learning/data/data_sources/course_local_data.dart';
import 'package:untitled3/core/util/styles.dart';
import 'package:go_router/go_router.dart';

class LearningHome extends StatefulWidget {
  const LearningHome({super.key});

  @override
  State<LearningHome> createState() => _LearningHomeState();
}

class _LearningHomeState extends State<LearningHome> {
  int selectedIndex = 0;

  void onCategorySelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<List<Course>> selectedCategory = [Alphabets, CommonPhrases, Numbers];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
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
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section matching home page design
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
                              // BACK BUTTON
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: kTextLight),
                                  onPressed: () {
                                    GoRouter.of(context).pop();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // TITLE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Learning Hub',
                                    style: Styles.textStyle30.copyWith(
                                      color: kTextLight,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: kFont,
                                    ),
                                  ),
                                  Text(
                                    'Today is a good day\nto learn something new!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: kTextLight.withOpacity(0.8),
                                      fontFamily: kFont,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Buttons Section
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 20, vertical: 20),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.15),
                  //       borderRadius: BorderRadius.circular(25),
                  //       border: Border.all(
                  //         color: Colors.white.withOpacity(0.3),
                  //         width: 1,
                  //       ),
                  //     ),
                  //     padding: const EdgeInsets.all(8),
                  //     child: Row(
                  //       children: [
                  //         Expanded(
                  //           child: CustomButton(
                  //             height: height * 0.05,
                  //             text: 'Alphabet',
                  //             index: 0,
                  //             onpressed: onCategorySelected,
                  //             selectedIndex: selectedIndex,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 8),
                  //         Expanded(
                  //           child: CustomButton(
                  //             height: height * 0.05,
                  //             text: 'Phrases',
                  //             index: 1,
                  //             onpressed: onCategorySelected,
                  //             selectedIndex: selectedIndex,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 8),
                  //         Expanded(
                  //           child: CustomButton(
                  //             height: height * 0.05,
                  //             text: 'Numbers',
                  //             index: 2,
                  //             onpressed: onCategorySelected,
                  //             selectedIndex: selectedIndex,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childCount: selectedCategory[selectedIndex].length,
                itemBuilder: (context, index) {
                  final course = selectedCategory[selectedIndex][index];
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(
                        AppRoute.courseDetail,
                        extra: course,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 18,
                                color: kTextLight,
                                fontWeight: FontWeight.bold,
                                fontFamily: kFont,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Image.asset(
                                  course.image,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Button with updated design
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.index,
    required this.text,
    required this.onpressed,
    required this.height,
    required this.selectedIndex,
  });

  final double height;
  final String text;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onpressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onpressed(index),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selectedIndex == index
              ? Colors.white.withOpacity(0.9)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: selectedIndex == index ? kPrimaryColor : kTextLight,
              fontWeight: FontWeight.bold,
              fontFamily: kFont,
            ),
          ),
        ),
      ),
    );
  }
}
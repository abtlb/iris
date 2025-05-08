import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/learning/presentation/pages/learning_start_screen.dart';
import 'package:untitled3/features/learning/domain/entities/course.dart';
import 'package:untitled3/features/learning/data/data_sources/course_local_data.dart';
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: BlueColor1,
                    size: 30,
                  ),
                  onPressed: () {
                    // التنقل إلى صفحة البداية
                    GoRouter.of(context).go('/learningStart');
                  },
                ),
                const Spacer(),
                const Icon(
                  Icons.search,
                  color: BlueColor1,
                  size: 30,
                ),
              ],
            ),
            SizedBox(height: height * 0.03),

            // الترحيب وصورة الملف الشخصي
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CustomText(
                      size: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      text: 'Hi There',
                    ),
                    CustomText(
                      size: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      text: 'Today is a good day ',
                    ),
                    CustomText(
                      size: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      text: 'to learn something new!',
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  height: height * 0.12,
                  width: width * 0.25,
                  decoration: BoxDecoration(
                    color: BlueColor1,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: BlueColor1.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/avtar-removebg-preview.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  height: height * 0.05,
                  text: 'Alphabet',
                  index: 0,
                  onpressed: onCategorySelected,
                  selectedIndex: selectedIndex,
                ),
                SizedBox(width: width * 0.05),
                CustomButton(
                  height: height * 0.05,
                  text: 'Common Phrases',
                  index: 1,
                  onpressed: onCategorySelected,
                  selectedIndex: selectedIndex,
                ),
                SizedBox(width: width * 0.05),
                CustomButton(
                  height: height * 0.05,
                  text: 'Number',
                  index: 2,
                  onpressed: onCategorySelected,
                  selectedIndex: selectedIndex,
                ),
              ],
            ),
            SizedBox(height: height * 0.03),

            Expanded(
              child: MasonryGridView.builder(
                crossAxisSpacing: 5,
                itemCount: selectedCategory[selectedIndex].length,
                gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final course = selectedCategory[selectedIndex][index];
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go(
                        '/course_detail',
                        extra: course,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: width * 0.45,
                        height: height * 0.3,
                        decoration: BoxDecoration(
                          color: course.bgcolor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: course.bgcolor.withOpacity(0.5),
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: height * 0.02),
                            CustomText(
                              size: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              text: course.title,
                            ),
                            SizedBox(height: height * 0.02),
                            Center(
                              child: Container(
                                height: height * 0.12,
                                child: Image.asset(course.image),
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
          ],
        ),
      ),
    );
  }
}

// زر مخصص
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
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selectedIndex == index ? SecondryColor.withOpacity(0.5) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: SecondryColor.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CustomText(
          size: 15,
          color: selectedIndex == index ? Colors.white : SecondryColor,
          fontWeight: FontWeight.bold,
          text: text,
        ),
      ),
    );
  }
}


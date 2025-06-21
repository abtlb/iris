import 'package:flutter/material.dart';
import 'package:untitled3/core/util/styles.dart';
import 'package:untitled3/core/util/widgets/custom_iconButton.dart';
import 'package:go_router/go_router.dart'; // إضافة GoRouter للانتقال بين الصفحات

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding:
        const EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // BACK BUTTON with blue color
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.blue),
                  onPressed: () {
                    // الانتقال إلى HomePage عند الضغط على السهم
                    context.go('/main'); // 'main' هو المسار لـ HomePage
                  },
                ),
                const SizedBox(width: 8),
                // TITLE with blue color
                Text(
                  'Chat with \nfriends',
                  style: Styles.textStyle30.copyWith(color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


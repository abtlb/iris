import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/styles.dart';
import 'package:untitled3/core/util/widgets/custom_iconButton.dart';
import 'package:untitled3/core/util/app_route.dart';

class CustomAppbarChat extends StatelessWidget {
  const CustomAppbarChat({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
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
                  fontFamily: kCarosFont,
                ),
              ),
            ),
            CustomIconButton(
              icon: FontAwesomeIcons.phoneFlip,
              color: const Color.fromARGB(255, 40, 18, 91),
              size: 45,
              iconSize: 18,
              onPressed: () {
                // TODO: start voice call
              },
            ),
          ],
        ),
      ),
    );
  }
}

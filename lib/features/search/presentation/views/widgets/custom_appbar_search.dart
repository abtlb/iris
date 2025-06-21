import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/widgets/custom_iconButton.dart';
import 'package:untitled3/features/search/presentation/views/widgets/search_textField.dart';

class CustomAppBarSearch extends StatelessWidget {
 const  CustomAppBarSearch({
    super.key, required this.onChanged,
  });
  
  final dynamic Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        spacing: 10,
        children: [
          CustomIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            color: kSecondaryColor,
            size: 45,
            iconSize: 18,
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),
          Expanded(
            child: SearchTextfield(
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

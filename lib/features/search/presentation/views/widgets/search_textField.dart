import 'package:flutter/material.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/styles.dart';

class SearchTextfield extends StatefulWidget {
  const SearchTextfield({super.key, required this.onChanged});
  final Function(String) onChanged;

  @override
  State<SearchTextfield> createState() => _SearchTextfieldState();
}

class _SearchTextfieldState extends State<SearchTextfield> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      showCursor: true,
      cursorColor: kPrimaryColor,
      style: Styles.textStyle16.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: kContainerColor,
        // suffix: Padding(
        //   padding: const EdgeInsets.only(top: 20),
        //   child: IconButton(
        //     onPressed: () {
        //       controller.clear();
        //     },
        //     icon: const Icon(
        //       Icons.clear_all_rounded,
        //       color: Colors.black,
        //     ),
        //   ),
        // ),
        prefixIcon: const Icon(
          Icons.search,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: kContainerColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: kContainerColor)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: kContainerColor)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: kContainerColor)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: kContainerColor)),
        hintText: "Search for someone to chat with...",
        hintStyle: Styles.textStyle16
            .copyWith(fontWeight: FontWeight.w600, color: Colors.black, fontFamily: kFont, fontSize: 15),
        errorStyle: Styles.textStyle16.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

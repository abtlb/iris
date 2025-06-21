import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/styles.dart' show Styles;
import 'package:untitled3/features/video_home/presentation/views/widgets/story_item.dart';

class CallItem extends StatelessWidget {
  const CallItem({super.key, required this.name});
final String name ;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          ListTile(
            leading:const  StoryItem(
              size: 40,
              sizeImage: 40,
              imageUrl: "",
            ),
            title:  Text(
              name,
              style: Styles.textStyle18,
            ),
            subtitle: Text(formateDate(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Styles.textStyle16),
            trailing: IconButton(
                onPressed: () {},
                icon: const Icon(
                  FontAwesomeIcons.phoneFlip,
                  color: kPrimaryColor,
                  size: 20,
                )),
          ),
          Divider(
            color: kContainerColor,
            indent: 110,
          )
        ],
      ),
    );
  }

  String formateDate() {
    return DateFormat('d MMMM, h:mm a').format(DateTime.now());
  }
}

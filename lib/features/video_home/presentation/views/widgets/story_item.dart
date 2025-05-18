import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class StoryItem extends StatelessWidget {
  const StoryItem({super.key, this.sizeImage, this.size, required this.imageUrl});
  final double? sizeImage, size;
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    print("image urllllll: $imageUrl");
    return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: size ?? 30,
          child: CircleAvatar(
            radius: sizeImage ?? 27,
            backgroundColor: Colors.blue,
            backgroundImage: imageUrl == null || imageUrl!.isEmpty? const AssetImage('assets/paper.png') : CachedNetworkImageProvider(imageUrl!),
          ),
        ));
  }
}
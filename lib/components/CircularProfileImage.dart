import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularProfileImage extends StatelessWidget {
  String? avatarUrl;
  double size;
  CircularProfileImage({Key? key, required this.avatarUrl,required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('------------------------avatar url--- ${avatarUrl}');
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: size,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => CircleAvatar(
          radius:size,
          backgroundColor: Colors.grey,
          backgroundImage: const AssetImage(
            'assets/images/icon_man.png',
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: size,
        backgroundColor: Colors.grey,
        backgroundImage: const AssetImage(
          'assets/images/icon_man.png',
        ),
      );
    }
  }
}

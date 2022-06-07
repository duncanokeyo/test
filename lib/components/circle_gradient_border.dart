import 'package:bridgemetherapist/utils/constants.dart';
import "package:flutter/material.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class CircleGradientBorder extends StatelessWidget {
  final String url;
  final double width, height, tickBorder;
  const CircleGradientBorder({
    required this.url,
    required this.width,
    required this.height,
    required this.tickBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: new LinearGradient(
          colors: [kColorDarkGreen, kColorDarkGreen],
        ),
      ),
      padding: EdgeInsets.all(tickBorder),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(tickBorder),
        child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(url)),
      ),
    );
  }
}

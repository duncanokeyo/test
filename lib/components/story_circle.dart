import 'package:bridgemetherapist/components/circle_gradient_border.dart';
import 'package:bridgemetherapist/model/Posts.dart';
import "package:flutter/material.dart";

class StoryCircle extends StatelessWidget {
  final Function press;
  final Post post;
  final double size;
  final double tickBorder;

  const StoryCircle({
    required this.press,
    required this.post,
    required this.size,
    required this.tickBorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        press();
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 1),
        child: Column(
          children: [
            CircleGradientBorder(
                url: post.avatarUrl!,
                width: size,
                height: size,
                tickBorder: tickBorder),
            Container(
              margin: EdgeInsets.symmetric(vertical: 2),
              child: Text(
                post.username!,
                style: TextStyle(color: Colors.black, fontSize: 13),
              ),
            )
          ],
        ),
      ),
    );
  }
}
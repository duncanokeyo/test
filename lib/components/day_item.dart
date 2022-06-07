import 'package:flutter/material.dart';

import '../utils/constants.dart';

class DayItem extends StatelessWidget {
  final String day;
  final bool selected;
  final void Function() onTap;

  const DayItem(
      {Key? key,
      required this.day,
      required this.onTap,
      required this.selected})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? kColorDarkGreen! : Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: <Widget>[
            Text(
              day,
              style: TextStyle(
                color: selected?kColorDarkGreen: kColorPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Text(
            //   time.split(' ')[1],
            //   style: TextStyle(
            //     color: selected?kColorDarkGreen: kColorPrimary,
            //     fontSize: 10,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

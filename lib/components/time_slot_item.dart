import 'package:bridgemetherapist/Utils.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class TimeSlotItem extends StatelessWidget {
  final TimeOfDay slot;
  final bool selected;
  final void Function() onTap;

  const TimeSlotItem(
      {Key? key,
      required this.slot,
      required this.onTap,
      required this.selected})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    String time = Utils.humanReadableTimeOfDay(slot);
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
              time.split(' ')[0],
              style: TextStyle(
                color: selected ? kColorDarkGreen : kColorPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              time.split(' ')[1],
              style: TextStyle(
                color: selected?kColorDarkGreen: kColorPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

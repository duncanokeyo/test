
import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/OngoingBookings.dart';
import 'package:bridgemetherapist/model/TherapistSessions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class DaySlotItem extends StatelessWidget {
  final bool selected;
  final List<TherapistSessions> therapistSessions;
  final DateTime selectedDateTime;
  final List<OnGoingBookings> onGoingBookings;
  final void Function() onTap;

  const DaySlotItem(
      {Key? key,
      required this.selected,
      required this.onTap,
      required this.therapistSessions,
      required this.selectedDateTime,
      required this.onGoingBookings})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 25,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? kColorDarkGreen! : Colors.grey,
            width: 2, //selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: <Widget>[
            Text(
              Utils.humanReadableDate(selectedDateTime),
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: kColorPrimaryDark, fontWeight: FontWeight.w600),
            ),
            Text(
              "${Utils.getSlotsAvailable(selectedDateTime, therapistSessions,onGoingBookings)} slots availabel",
              style: TextStyle(
                color: selected ? kColorDarkGreen : kColorPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/components/CircularProfileImage.dart';
import 'package:bridgemetherapist/controller/UpcomingSessionsController.dart';
import 'package:bridgemetherapist/countdown/count_down_flutter.dart';
import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:bridgemetherapist/pages/appointment/appointment_detail_page.dart';
import 'package:bridgemetherapist/pages/home/widgets/widgets.dart';
import 'package:bridgemetherapist/pages/messages/direct_messages_detail_page.dart';
import 'package:bridgemetherapist/pages/sessionNotes/SessionNotesList.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../../components/round_icon_button.dart';
import '../../../utils/constants.dart';

class NextAppointmentWidget extends StatelessWidget {
  UpcomingSessionsController controller =
      Get.find<UpcomingSessionsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        DateTime now = DateTime.now();
        DateTime formatDateTime = DateTime(now.year, now.month, now.day);
        SessionBookings? currentSession = Utils.currentBooking(
            controller.results.toList(), formatDateTime,
            checkPayment: false);

        if (currentSession != null) {
          return Column(
            children: [
              SectionHeaderWidget(
                title: 'current_session'.tr(),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DirectMessagesDetailPage(
                            sessionBookings: currentSession)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: kColorGreen,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${Utils.humanReadableDate(currentSession.dateBooked)}, ${currentSession.time.format(context)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                // Text(
                                //   'tomorrow'.tr(),
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 25,
                                //     fontWeight: FontWeight.w400,
                                //   ),
                                // ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // Text(
                                //   "${Utils.humanReadableDate(bookings.dateBooked)}, ${bookings.time.format(context)}",
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 14,
                                //     fontWeight: FontWeight.w300,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 40,
                        thickness: 0.5,
                      ),
                      Row(
                        children: <Widget>[
                          CircularProfileImage(
                            avatarUrl: currentSession.avatarUrl,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                currentSession.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              const Text(
                                'Client',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Ends at ${Utils.humanReadableTimeOfDay(Utils.getSessionEndTime(currentSession.time, currentSession.slotSize))}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          )

                          // Countdown(
                          //   duration: Duration(seconds: 60),
                          //   onFinish: () {},
                          //   builder: (BuildContext ctx, Duration remaining) {
                          //     if (remaining.inMinutes <= 1) {
                          //       return Text(
                          //         '${remaining.inHours}:${remaining.inMinutes}:${remaining.inSeconds % 60} secs remaining',
                          //         style: const TextStyle(
                          //             fontSize: 15.5,
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.w700,
                          //             fontFamily: 'Gotik'),
                          //       );
                          //     } else {
                          //       return Text(
                          //         '${remaining.inHours}:${remaining.inMinutes}:${remaining.inSeconds % 60} secs remaining',
                          //         style: const TextStyle(
                          //             fontSize: 15.5,
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.w700,
                          //             fontFamily: 'Gotik'),
                          //       );
                          //     }
                          //   },
                          // )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          SessionBookings? bookings =
              Utils.upComingSession(controller.results.toList());
          if (bookings == null) {
            return Column(
              children: [
                SectionHeaderWidget(
                  title: 'no_upcoming_appointment'.tr(),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.sessions);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: kColorGreen,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'no_upcoming_appointment_message'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  // Text(
                                  //   'tomorrow'.tr(),
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 25,
                                  //     fontWeight: FontWeight.w400,
                                  //   ),
                                  // ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  // Text(
                                  //   "${Utils.humanReadableDate(bookings.dateBooked)}, ${bookings.time.format(context)}",
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 14,
                                  //     fontWeight: FontWeight.w300,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 40,
                          thickness: 0.5,
                        ),
                        Row(
                          children: const <Widget>[
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                SectionHeaderWidget(
                  title: 'next_appointment'.tr(),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AppointmentDetailPage(sessionBooking: bookings)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: kColorGreen,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${Utils.humanReadableDate(bookings.dateBooked)}, ${bookings.time.format(context)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  // Text(
                                  //   'tomorrow'.tr(),
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 25,
                                  //     fontWeight: FontWeight.w400,
                                  //   ),
                                  // ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  // Text(
                                  //   "${Utils.humanReadableDate(bookings.dateBooked)}, ${bookings.time.format(context)}",
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 14,
                                  //     fontWeight: FontWeight.w300,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 40,
                          thickness: 0.5,
                        ),
                        Row(
                          children: <Widget>[
                            CircularProfileImage(
                              avatarUrl: bookings.avatarUrl,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  bookings.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                const Text(
                                  'Client',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }
      },
    );
  }
}

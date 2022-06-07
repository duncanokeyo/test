import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:bridgemetherapist/pages/appointment/completed_appointment_detail_page.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';

class HistoryAppointmentListItem extends StatelessWidget {
  SessionBookings sessionBookings;
  HistoryAppointmentListItem({required this.sessionBookings});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Column(
        children: [
          ListTile(
            // leading: Container(
            //   margin: EdgeInsets.all(10.0),
            //   decoration:
            //       BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            // ),
            //leading: Text(sessionBookings.isPaid()),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor:
                  sessionBookings.isPaid() ? kColorDarkGreen : Colors.amber,
              child: Text(
                sessionBookings.isPaid() ? "Paid" : "Not paid",
                style: TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
            title: Text(
              sessionBookings.username,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text(
              "Client",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: SizedBox(
              height: 40,
              width: 40,
              child: CachedNetworkImage(
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 30,
                  backgroundImage: imageProvider,
                ),
                imageUrl: sessionBookings.avatarUrl,
                errorWidget: (contex, url, error) {
                  return CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      "assets/images/icon_doctor_5.png",
                      fit: BoxFit.fill,
                    ),
                  );
                },
              ),
            ),
          ),
          Divider(
            color: Colors.grey[100],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Wrap(
                spacing: 20,
                runAlignment: WrapAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: kColorDarkGreen,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(Utils.humanReadableDate(sessionBookings.dateBooked)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timelapse,
                        color: kColorDarkGreen,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(Utils.humanReadableTimeOfDay(sessionBookings.time)),
                    ],
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      const Text("Completed"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                if (!sessionBookings.isPaid()) ...[
                  // Expanded(
                  //   child: Container(
                  //     child: CustomOutlineButton(
                  //       text: 'cancel',
                  //       textSize: 14,
                  //       onPressed: () async {
                  //         print('cancel called');
                  //         //cancel the session
                  //         ProgressDialog pd = ProgressDialog(context: context);
                  //         pd.show(max: 100, msg: 'Cancelling session');

                  //         var response = await supabase
                  //             .from('session_bookings')
                  //             .delete()
                  //             .eq('id', sessionBookings.id)
                  //             .execute();

                  //         pd.close();
                  //         if (response.hasError) {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             SnackBar(
                  //               content: Text("Error cancelling session"),
                  //             ),
                  //           );
                  //           return;
                  //         }

                  //         Get.find<UpcomingSessionsController>().fetch(true);

                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(
                  //             content: Text("Cancelled session"),
                  //           ),
                  //         );
                  //         print("cancell");
                  //         //    cancel();
                  //       },
                  //       padding: const EdgeInsets.symmetric(
                  //         vertical: 5,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
                const SizedBox(
                  width: 5,
                ),
                // Expanded(
                //   child: Container(
                //     child: CustomButton(
                //       text: 'Reschedule',
                //       textSize: 14,
                //       onPressed: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => RescheduleAppointment(
                //                   therapistId: sessionBookings.profileId,
                //                   therapistAvatarUrl: sessionBookings.avatarUrl,
                //                   slotSize: sessionBookings.slotSize,
                //                   sessionBookingId: sessionBookings.id,
                //                   speciality: sessionBookings.specialization[0],
                //                   therapistName: sessionBookings.username)),
                //         );
                //       },
                //       padding: const EdgeInsets.symmetric(
                //         vertical: 5,
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   width: 5,
                // ),
                Expanded(
                  child: Container(
                    child: CustomButton(
                      text: 'view',
                      textSize: 14,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CompletedAppointmentDetailPage(
                                  sessionBooking: sessionBookings)),
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );

    // return Card(
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: <Widget>[
    //       SizedBox(
    //         height: 20,
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 15),
    //         child: Row(
    //           children: <Widget>[
    //             Expanded(
    //               child: Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                   Expanded(
    //                     child: _buildColumn(
    //                       context: context,
    //                       title: 'date'.tr(),
    //                       subtitle: Utils.humanReadableDate(
    //                           sessionBookings.dateBooked),
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     width: 10,
    //                   ),
    //                   Expanded(
    //                     child: _buildColumn(
    //                       context: context,
    //                       title: 'time'.tr(),
    //                       subtitle: sessionBookings.time.format(context),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             const SizedBox(
    //               width: 10,
    //             ),
    //             CustomButton(
    //               text: 'view'.tr(),
    //               textSize: 14,
    //               onPressed: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                       builder: (context) => CompletedAppointmentDetailPage(
    //                           sessionBooking: sessionBookings)),
    //                 );
    //               },
    //               padding: const EdgeInsets.symmetric(
    //                 vertical: 10,
    //                 horizontal: 5,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       const SizedBox(
    //         height: 15,
    //       ),
    //       const Divider(
    //         height: 1,
    //         thickness: 1,
    //         indent: 10,
    //         endIndent: 10,
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.all(15),
    //         child: Row(
    //           children: <Widget>[
    //             Expanded(
    //               child: Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                   Expanded(
    //                     child: _buildColumn(
    //                       context: context,
    //                       title: 'doctor'.tr(),
    //                       subtitle: sessionBookings.username,
    //                     ),
    //                   ),
    //                   Expanded(
    //                     child: _buildColumn(
    //                       context: context,
    //                       title: 'speciality'.tr(),
    //                       subtitle: sessionBookings.specialization.first,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             SizedBox(
    //               width: 10,
    //             ),
    //             Visibility(
    //               visible: false,
    //               maintainAnimation: true,
    //               maintainSize: true,
    //               maintainState: true,
    //               child: CustomButton(
    //                 text: 'view'.tr(),
    //                 textSize: 14,
    //                 onPressed: () {},
    //                 padding: EdgeInsets.symmetric(
    //                   vertical: 10,
    //                   horizontal: 5,
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Column _buildColumn({
    required BuildContext context,
    required String title,
    required subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:bridgemetherapist/pages/messages/direct_messages_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../components/custom_button.dart';
import '../../data/pref_manager.dart';
import '../../utils/constants.dart';

class AppointmentDetailPage extends StatefulWidget {
  SessionBookings sessionBooking;

  AppointmentDetailPage({required this.sessionBooking});

  @override
  _AppointmentDetailPageState createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final bool _isdark = Prefs.isDark();

  Color get _color => _isdark ? kColorDark : Colors.white;
  var selectedPaymentMethod;
  var sendingPaymentRequest = false;

  _completeAppointment(context) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'Completing appointment');

    var updateEndTime = await supabase
        .from('session_bookings')
        .update({'completed': true})
        .eq('id', widget.sessionBooking.id)
        .execute();

    if (updateEndTime.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error completing appointmnet")));
      pd.close();
    }

    setState(() {
      widget.sessionBooking.completed = true;
    });
    pd.close();
  }

  Widget dateAndTime() {
    return Container(
      width: double.infinity,
      color: _color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Text(
              'date_and_time'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${Utils.humanReadableDate(widget.sessionBooking.dateBooked)} ${widget.sessionBooking.time.format(context)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget price() {
    return Container(
      width: double.infinity,
      color: _color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Text(
              'appointment_bill'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Kes ${widget.sessionBooking.amount}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'status'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Pending",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appointmentDetails() {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sessionBooking.username,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Text(
                      //   widget.sessionBooking.specialization[0],
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey,
                      //     fontWeight: FontWeight.w700,
                      //   ),
                      // ),
                    ],
                  ),
                  const Spacer(),
                  CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 30,
                      backgroundImage: imageProvider,
                    ),
                    imageUrl: widget.sessionBooking.avatarUrl,
                    errorWidget: (contex, url, error) {
                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(
                          "assets/images/icon_man.png",
                          fit: BoxFit.fill,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.grey[100],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: kColorDarkGreen,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(Utils.humanReadableDate(
                      widget.sessionBooking.dateBooked)),
                  const SizedBox(
                    width: 20,
                  ),
                  const Icon(
                    Icons.timelapse,
                    color: kColorDarkGreen,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(widget.sessionBooking.time.format(context)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.amber, shape: BoxShape.circle),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  const Text("Pending"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentsAndDistribution() {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Total Cost",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "KSH ${widget.sessionBooking.amount}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  const Text(
                    "Duration",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${widget.sessionBooking.slotSize} mins",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              Divider(height: 0.1, color: Colors.grey[100]),
              const SizedBox(
                height: 6,
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      color: kColorDarkGreen,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text("Payment status"),
                    const Spacer(),
                    if (widget.sessionBooking.isPaid()) ...[
                      Chip(
                        backgroundColor: Colors.amber,
                        label: Text(
                          "Paid",
                          style: TextStyle(color: Colors.amber[900]),
                        ),
                      ),
                    ] else ...[
                      Chip(
                        backgroundColor: Colors.amber,
                        label: Text(
                          "Pending",
                          style: TextStyle(color: Colors.amber[900]),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bookingDetails() {
    return Container(
      width: double.infinity,
      color: _color,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 15,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'booked_for'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.sessionBooking.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
                child: VerticalDivider(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'appointment_id'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.sessionBooking.refNo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  _navigate() {
    Navigator.of(NavigationService.navigatorKey.currentContext!).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => DirectMessagesDetailPage(
          sessionBookings: widget.sessionBooking,
        ),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return Opacity(
            opacity: animation.value,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const _txtStyle = TextStyle(
        fontSize: 15.5,
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontFamily: 'Gotik');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'appointment_details'.tr(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
                onPressed: () {
                  _navigate();
                },
                icon: Icon(Icons.message, color: kColorDarkGreen)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: kIsWeb
              ? const EdgeInsets.only(left: WEBPADDING, right: WEBPADDING)
              : const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 20.0, bottom: 20.0, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text(
                              "Appointment details",
                              style: _txtStyle,
                            ),
                          ],
                        ),
                      ),

                      appointmentDetails(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 20.0, bottom: 20.0, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text(
                              "Payment and duration",
                              style: _txtStyle,
                            ),
                          ],
                        ),
                      ),
                      paymentsAndDistribution(),
                      if (widget.sessionBooking.completed) ...[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomButton(
                            text: 'Back',
                            textSize: 14,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomButton(
                            text: 'Complete',
                            textSize: 14,
                            color: Colors.red,
                            onPressed: () {
                              _completeAppointment(context);
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                          ),
                        ),
                      ]

                      // Padding(
                      //   padding:
                      //       EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      //   child: RichText(
                      //     text: TextSpan(
                      //       children: [
                      //         TextSpan(
                      //           text: '${'follow_procedure'.tr()} ',
                      //           style: TextStyle(
                      //             color: Colors.grey[600],
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w400,
                      //           ),
                      //         ),
                      //         TextSpan(
                      //           text: 'my_appointments'.tr(),
                      //           style: TextStyle(
                      //             color: kColorDarkGreen,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w400,
                      //             decoration: TextDecoration.underline,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:bridgemetherapist/pages/messages/direct_messages_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/pref_manager.dart';
import '../../utils/constants.dart';

class CompletedAppointmentDetailPage extends StatefulWidget {
  SessionBookings sessionBooking;

  CompletedAppointmentDetailPage({required this.sessionBooking});

  @override
  _CompletedAppointmentDetailPageState createState() =>
      _CompletedAppointmentDetailPageState();
}

class _CompletedAppointmentDetailPageState
    extends State<CompletedAppointmentDetailPage> {
  final bool _isdark = Prefs.isDark();

  Color get _color => _isdark ? kColorDark : Colors.white;
  var selectedPaymentMethod;
  var sendingPaymentRequest = false;
  Widget dateAndTime() {
    return Container(
      width: double.infinity,
      color: _color,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text(
              'date_and_time'.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "${Utils.humanReadableDate(widget.sessionBooking.dateBooked)} ${widget.sessionBooking.time.format(context)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  // Widget practiceDetail() {
  //   return Container(
  //     width: double.infinity,
  //     color: _color,
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 15),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           SizedBox(
  //             height: 15,
  //           ),
  //           Text(
  //             'practice_detail'.tr(),
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Text(
  //             'YourHealth Medical Centre',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           Text(
  //             '3719  Jehovah Drive, Roanoke, Virginia - 24011',
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           InkWell(
  //             onTap: () {},
  //             child: Text(
  //               'get_direction'.tr().toUpperCase(),
  //               style: TextStyle(
  //                 color: kColorGreen,
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: 5,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget procedure() {
  //   return Container(
  //     width: double.infinity,
  //     color: _color,
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 15),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           SizedBox(
  //             height: 15,
  //           ),
  //           Text(
  //             'procedure'.tr(),
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Text(
  //             'Consultation',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           SizedBox(
  //             height: 5,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget price() {
    return Container(
      width: double.infinity,
      color: _color,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text(
              'appointment_bill'.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Kes ${widget.sessionBooking.amount}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'status'.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
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
        padding: EdgeInsets.all(15),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.sessionBooking.specialization[0],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 25,
                      backgroundImage: imageProvider,
                    ),
                    imageUrl: widget.sessionBooking.avatarUrl,
                    errorWidget: (contex, url, error) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(
                          "assets/images/icon_doctor_5.png",
                          fit: BoxFit.fill,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.grey[100],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: kColorDarkGreen,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(Utils.humanReadableDate(
                      widget.sessionBooking.dateBooked)),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.timelapse,
                    color: kColorDarkGreen,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(widget.sessionBooking.time.format(context)),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: kColorDarkGreen, shape: BoxShape.circle),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text("Completed"),
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
                  Text(
                    "Total Cost",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "KSH ${widget.sessionBooking.amount}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  Text(
                    "Duration",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "KSH ${widget.sessionBooking.slotSize} mins",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Divider(height: 0.1, color: Colors.grey[100]),
              SizedBox(
                height: 6,
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: kColorDarkGreen,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Payment status"),
                    Spacer(),
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
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
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
              Container(
                height: 80,
                child: VerticalDivider(),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'appointment_id'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.sessionBooking.refNo,
                        style: TextStyle(
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
          SizedBox(
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
        transitionDuration: Duration(milliseconds: 600),
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
    const _txtStyle = const TextStyle(
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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(10.0),
        //     child: InkWell(
        //       onTap: () => _navigate(),
        //       child: const Icon(Icons.message,color: kColorDarkGreen,),
        //     ),
        //   )
        // ],
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
                          children: <Widget>[
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
                          children: <Widget>[
                            Text(
                              "Payment and duration",
                              style: _txtStyle,
                            ),
                          ],
                        ),
                      ),
                      paymentsAndDistribution(),

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

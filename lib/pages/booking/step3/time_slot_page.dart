import 'dart:collection';


import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/controller/TherapistSessionsController.dart';
import 'package:bridgemetherapist/model/TherapistSessions.dart';
import 'package:bridgemetherapist/model/Therpist.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart' hide Trans;

import '../../../components/day_slot_item.dart';
import '../../../components/time_slot_item.dart';
import '../../../data/pref_manager.dart';
import '../../../model/doctor.dart';
import '../../../routes/routes.dart';

class TimeSlotPage extends StatefulWidget {
  String therapistId;

  TimeSlotPage({required this.therapistId});

  @override
  _TimeSlotPageState createState() => _TimeSlotPageState();
}

class _TimeSlotPageState extends State<TimeSlotPage> {
  TherapistSessionController controller =
      Get.find<TherapistSessionController>();

  int _selectedIndex = 0;
  Map<SelectedTimeSlot, bool> selectedTimeSlots = HashMap();

  _TimeSlotPageState();

  @override
  void initState() {
    controller.fetch(true, widget.therapistId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('time_slot'.tr()),
      ),
      body: Obx(
        () {
          if (controller.isLoading.isTrue) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isNotEmpty) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: InkWell(
                  onTap: () {
                    controller.fetch(true, widget.therapistId);
                  },
                  child: Text("Error fetching sessions tap to refresh"),
                ),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isEmpty &&
              controller.results.isEmpty) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: InkWell(
                  onTap: () {
                    controller.fetch(true, widget.therapistId);
                  },
                  child: Text("No sessions"),
                ),
              ),
            );
          } else {
            List<DateTime> items =
                Utils.getDaysInRangeList(controller.results.toList());

            items = Utils.removePastDates(items, controller.accurateDate);
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  
                  Container(
                    width: double.infinity,
                    height: 85,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    color: Prefs.getBool(Prefs.DARKTHEME, def: false)
                        ? Colors.white.withOpacity(0.12)
                        : Colors.grey[300],
                    child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                        width: 10,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        //print('displaying day slot item for index $index');
                        //print(items[index]);
                        return DaySlotItem(
                          onGoingBookings :controller.ongoingBookings.toList(),
                          therapistSessions: controller.results.toList(),
                          selectedDateTime: items[index],
                          onTap: () {
                            setState(
                              () {
                                _selectedIndex = index;
                              },
                            );
                          },
                          selected: _selectedIndex == index,
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        Utils.humanReadableDate(items[_selectedIndex]),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  _slot(context, 1, 'morning'.tr(), '08:30 AM',
                      items[_selectedIndex]),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RawMaterialButton(
                      onPressed: () {
                        if (selectedTimeSlots.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("No time slot selected"),
                            ),
                          );
                        } else {
                          List<SelectedTimeSlot> selectedSlots = [];
                          selectedTimeSlots.forEach((key, value) {
                            if (value) {
                              selectedSlots.add(key);
                            }
                          });

                          if (selectedSlots.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("No time slot selected"),
                              ),
                            );
                          } else {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PatientDetailsPage(
                            //       timeSlots: selectedSlots,
                            //       therapist: therapist,
                            //     ),
                            //   ),
                            // );
                          }
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      fillColor: kColorGreen,
                      child: Container(
                        height: 40,
                        child: Center(
                          child: Text(
                            'proceed'.tr().toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _slot(context, int periodCode, String periodName, String time,
      DateTime selectedDate) {
    List<TimeOfDay> slots =
        Utils.getSlots(selectedDate, controller.results.toList());

    slots = Utils.removeBookedTimes(slots, controller.ongoingBookings.toList(),selectedDate);

    TherapistSessions? sessions =
        Utils.getTherapistSessions(selectedDate, controller.results.toList());
    if (slots.isEmpty) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: Center(
          child: Text("No time time slots for the selected date"),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$time ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${slots.length} ${'slots'.tr().toLowerCase()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          
          StaggeredGridView.countBuilder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            crossAxisCount: 4,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: slots.length,
            staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemBuilder: (context, index) {
              SelectedTimeSlot x = SelectedTimeSlot(
                  date: selectedDate,
                  timeOfDay: slots[index],
                  session: sessions!);
              return TimeSlotItem(
                selected: selectedTimeSlots.containsKey(x) &&
                    selectedTimeSlots[x] == true,
                slot: slots[index],
                onTap: () {
                  print("ontap");
                  bool hasKey = selectedTimeSlots.containsKey(x);

                  print('-----contains key $hasKey');
                  if (hasKey) {
                    selectedTimeSlots[x] = !selectedTimeSlots![x]!;
                  } else {
                    selectedTimeSlots[x] = true;
                  }
                  print(selectedTimeSlots);

                  setState(() {});
                  //Navigator.of(context).pushNamed(Routes.bookingStep4);
                },
              );
            },
          ),
        ],
      );
    }
  }
}

class SelectedTimeSlot extends Equatable {
  DateTime date;
  TimeOfDay timeOfDay;
  TherapistSessions session;
  SelectedTimeSlot(
      {required this.date, required this.timeOfDay, required this.session});

  // @override
  // bool operator ==(o) =>
  //     o is SelectedTimeSlot &&
  //     date.day == o.date.day &&
  //     date.month == o.date.month &&
  //     o.date.year == date.year &&
  //     timeOfDay.hour == o.timeOfDay.hour &&
  //     o.timeOfDay.minute == timeOfDay.minute;

  // @override
  // // TODO: implement hashCode
  // int get hashCode => super.hashCode;

  @override
  // TODO: implement props
  List<Object?> get props => [date, timeOfDay];
}

import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:bridgemetherapist/model/TherapistSessions.dart';
import 'package:flutter/material.dart';
import 'extensions.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'model/DiscussionCategories.dart';
import 'model/OngoingBookings.dart';
import 'model/SessionBookings.dart';
import 'pages/booking/step3/time_slot_page.dart';

class Utils {
  static double timeOfDayToDouble(TimeOfDay myTime) =>
      myTime.hour + myTime.minute / 60.0;

  static String getTimeAgo(DateTime date) {
    return timeago.format(date, locale: 'en', allowFromNow: true);
  }

  static String humanReadableTimeOfDay(TimeOfDay tod) {
    String minutes = tod.minute.toString().padLeft(2, "0");
    int hour = tod.hour;
    int ampm = hour - 12;

    if (ampm <= 0) {
      ampm = hour;
    }
    String hour_ = ampm.toString().padLeft(2, "0");

    String postFix;

    if (hour < 12) {
      postFix = "am";
    } else {
      postFix = "pm";
    }
    return "$hour_:$minutes $postFix";
  }

  static String timeAgoFromDateString(String date) {
    DateTime dateTime = DateTime.parse(date);
    return getTimeAgo(dateTime);
  }

  static TimeOfDay timeOfDayFromString(String string) {
    TimeOfDay results = TimeOfDay(
        hour: int.parse(string.split(":")[0]),
        minute: int.parse(string.split(":")[1]));

    return results;
  }

  static List<DateTime> getDaysInRange(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    DateTime tmp = DateTime(startDate.year, startDate.month, startDate.day, 12);
    while (DateTime(tmp.year, tmp.month, tmp.day) != endDate) {
      days.add(DateTime(tmp.year, tmp.month, tmp.day));
      tmp = tmp.add(new Duration(days: 1));
    }
    days.add(endDate);
    return days;
  }

  static int timeOfDayDifference(TimeOfDay a, TimeOfDay b) {
    int nowSec = (a.hour * 60 + a.minute) * 60;
    int veiSec = (b.hour * 60 + b.minute) * 60;

    print('now is $nowSec   later is $veiSec');
    print('a is ${a} b is ${b}');
    int dif = nowSec - veiSec;
    return dif;
  }

  static bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  static String getTimeOfDayParam(TimeOfDay timeOfDay) {
    return "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}";
  }

  static String getMpesaPassWord(shortCode, passkey, timestamp) {
    String string = "$shortCode$passkey$timestamp";
    return base64Encode(string.codeUnits);
  }

  //checks if the widget is in the timerange
  static String isSessionInTimeRange(
      DateTime dateBooked, TimeOfDay time, int slotSize) {
    DateTime today_ = DateTime.now();
    DateTime today = DateTime(today_.year, today_.month, today_.day);
    TimeOfDay timeOfDay = TimeOfDay.now();

    if (dateBooked.isAfter(today)) {
      return "The session is scheduled for ${humanReadableDate(dateBooked)}";
    }

    print("comparing ${dateBooked.toString()} to ${today.toString()}");
    if (dateBooked.isBefore(today)) {
      return "The session is past scheduled, booking was on ${humanReadableDate(dateBooked)}";
    }

    if (dateBooked.day == today.day &&
        dateBooked.month == today.month &&
        dateBooked.year == today.year) {
      //booking is on the same day
      //check if the time is on the range..
      TimeOfDay timeEnd = time.plusMinutes(slotSize);

      if ((time.compareTo(timeOfDay) == -1 || time.compareTo(timeOfDay) == 0) &&
          (timeEnd.compareTo(timeOfDay) == 0 ||
              timeEnd.compareTo(timeOfDay) == 1)) {
        print('match found');
        return "";
      } else {
        return "Session starts at ${time}";
      }
    }
    return "";
  }

  static SessionBookings? currentBooking(
      List<SessionBookings> activeSessions, DateTime? accurateDate,
      {bool? checkPayment}) {
    TimeOfDay timeOfDay =
        TimeOfDay.now(); //todo get accurate timeofday from server..

    SessionBookings? results;

    for (var element in activeSessions) {
      if (accurateDate != null &&
          element.dateBooked.day == accurateDate.day &&
          element.dateBooked.month == accurateDate.month &&
          element.dateBooked.year == accurateDate.year) {
        print('--------------------------> PASSED ${element.dateBooked}');

        TimeOfDay timeEnd = element.time.plusMinutes(element.slotSize);
        print("start time --- ${element.time}");
        print("end time ---- ${timeEnd}");

        if ((element.time.compareTo(timeOfDay) == -1 ||
                element.time.compareTo(timeOfDay) == 0) &&
            (timeEnd.compareTo(timeOfDay) == 0 ||
                timeEnd.compareTo(timeOfDay) == 1)) {
          print('match found');
          if (element.isPaid()) {
            results = element;
          }
        }
      } else if (accurateDate == null) {
        TimeOfDay timeEnd = element.time.plusMinutes(element.slotSize);
        print("start time --- ${element.time}");
        print("end time ---- ${timeEnd}");

        if ((element.time.compareTo(timeOfDay) == -1 ||
                element.time.compareTo(timeOfDay) == 0) &&
            (timeEnd.compareTo(timeOfDay) == 0 ||
                timeEnd.compareTo(timeOfDay) == 1)) {
          print('match found');
          if (element.isPaid()) {
            results = element;
          }
        }
      }
    }

    print('--------------------results date booked ----${results?.dateBooked}');
    return results;
  }

  static String getMpesaTimestamp() {
    var date = new DateTime.now();

    var day = date.day;
    var year = date.year;
    var month = date.month + 1;
    var hour = date.hour;
    var minute = date.minute;
    var seconds = date.second;

    var dayString = day <= 9 ? "0" + day.toString() : day.toString();
    var monthString = month <= 9 ? "0" + month.toString() : month.toString();
    var hourString = hour <= 9 ? "0" + hour.toString() : hour.toString();
    var minuteString =
        minute <= 9 ? "0" + minute.toString() : minute.toString();
    var secondsString =
        seconds <= 9 ? "0" + seconds.toString() : seconds.toString();

    return year.toString() +
        "" +
        monthString +
        "" +
        dayString +
        "" +
        hourString +
        "" +
        minuteString +
        "" +
        secondsString;
  }

  static List<DateTime> getDaysInRangeList(List<TherapistSessions> results) {
    List<DateTime> _results = [];
    results.forEach((element) {
      var daysAvailable = element.daysAvailable;
      List<DateTime> items = getDaysInRange(element.startDate, element.endDate);
      items = items.where((element) {
        //remove days not available
        var dayOfWeek = element.weekday;
        return daysAvailable[dayOfWeek - 1] == 1;
      }).toList();
      _results.addAll(items);
    });
    return _results;
  }

  static String timeOfDayToAmPm(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  static String displaydate(DateTime startDate) {
    return DateFormat.yMd().format(startDate);
  }

  static String humanReadableDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  static String displayDateRangeFromDateTime(List<DateTime> dates) {
    return "From ${DateFormat.yMd().format(dates[0])} to ${DateFormat.yMd().format(dates[dates.length - 1])}";
  }

  static String displayDateRange(DateTimeRange? selectedDateTimeRange) {
    if (selectedDateTimeRange == null) {
      return "";
    }
    return "From ${DateFormat.yMd().format(selectedDateTimeRange.start)} to ${DateFormat.yMd().format(selectedDateTimeRange.end)}";
  }

  static String upperCaseFirstLetter(String? string) {
    if (string == null) {
      return "";
    }
    return (string[0].toUpperCase() + string.substring(1).toLowerCase()).trim();
  }

  static List<TimeOfDay> getSlots(
      DateTime selectedDateTime, List<TherapistSessions> therapistSessions) {
    TherapistSessions? sessions;

    therapistSessions.forEach(
      (element) {
        if ((element.startDate.year == selectedDateTime.year &&
                element.startDate.month == selectedDateTime.month &&
                element.startDate.day == selectedDateTime.day) ||
            (element.startDate.isBefore(selectedDateTime))) {
          if ((element.endDate.year == selectedDateTime.year &&
                  element.endDate.month == selectedDateTime.month &&
                  element.endDate.day == selectedDateTime.day) ||
              (element.endDate.isAfter(selectedDateTime))) {
            sessions = element;
          }
        }
      },
    );

    if (sessions == null) {
      return [];
    }

    return getTimes(
            sessions!.sessionTimes[0].startTime,
            sessions!.sessionTimes[0].endTime,
            Duration(minutes: sessions!.sessionTimes[0].slotSize))
        .toList();
  }

  static String getParamTimeFormat(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    print(formatter.format(dateTime));
    return formatter.format(dateTime);
  }

  static String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  static Map<DateTime, List<SelectedTimeSlot>> groupTimeSlots(
      List<SelectedTimeSlot> slots) {
    Map<DateTime, List<SelectedTimeSlot>> results = HashMap();

    slots.forEach((element) {
      if (results.containsKey(element.date)) {
        results[element.date]!.add(element);
      } else {
        results[element.date] = [element];
      }
    });
    return results;
  }

  static TherapistSessions? getTherapistSessions(
      DateTime selectedDateTime, List<TherapistSessions> therapistSessions) {
    TherapistSessions? sessions;
    therapistSessions.forEach(
      (element) {
        if ((element.startDate.year == selectedDateTime.year &&
                element.startDate.month == selectedDateTime.month &&
                element.startDate.day == selectedDateTime.day) ||
            (element.startDate.isBefore(selectedDateTime))) {
          if ((element.endDate.year == selectedDateTime.year &&
                  element.endDate.month == selectedDateTime.month &&
                  element.endDate.day == selectedDateTime.day) ||
              (element.endDate.isAfter(selectedDateTime))) {
            sessions = element;
          }
        }
      },
    );
    return sessions;
  }

  static int getSlotsAvailable(
      DateTime selectedDateTime,
      List<TherapistSessions> therapistSessions,
      List<OnGoingBookings> onGoingBookings) {
    //get the therapist sessions
    TherapistSessions? sessions;
    therapistSessions.forEach(
      (element) {
        if ((element.startDate.year == selectedDateTime.year &&
                element.startDate.month == selectedDateTime.month &&
                element.startDate.day == selectedDateTime.day) ||
            (element.startDate.isBefore(selectedDateTime))) {
          if ((element.endDate.year == selectedDateTime.year &&
                  element.endDate.month == selectedDateTime.month &&
                  element.endDate.day == selectedDateTime.day) ||
              (element.endDate.isAfter(selectedDateTime))) {
            sessions = element;
          }
        }
      },
    );

    //print(sessions);
    if (sessions == null) {
      return 0;
    } else {
      var filter = removeBookedTimes(
          getTimes(
                  sessions!.sessionTimes[0].startTime,
                  sessions!.sessionTimes[0].endTime,
                  Duration(minutes: sessions!.sessionTimes[0].slotSize))
              .toList(),
          onGoingBookings,
          selectedDateTime);

      return filter.length;
      // return getTimes(
      //         sessions!.sessionTimes[0].startTime,
      //         sessions!.sessionTimes[0].endTime,
      //         Duration(minutes: sessions!.sessionTimes[0].slotSize))
      //     .length;
    }
  }

  static bool isValidInt(String s) {
    return int.tryParse(s) != null;
  }

  static Iterable<TimeOfDay> getTimes(
      TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;

    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour ||
        (hour == endTime.hour && minute <= endTime.minute));
  }

  static List<DateTime> removePastDates(List<DateTime> items, accurateDate) {
    List<DateTime> results = [];
    items.forEach((element) {
      if (!element.isBefore(accurateDate)) {
        results.add(element);
      }
    });
    return results;
  }

  static String stripMessage(String? message) {
    if (message == null) {
      return "";
    }
    var split = message.split('\n');
    return split[0];
  }

  static List<TimeOfDay> removeBookedTimes(List<TimeOfDay> slots,
      List<OnGoingBookings> list, DateTime selectedDate) {
    List<OnGoingBookings> bookings = list;
    bookings = bookings.where((element) {
      if (element.dateBooked.day == selectedDate.day &&
          element.dateBooked.year == selectedDate.year &&
          element.dateBooked.month == selectedDate.month) {
        return true;
      } else {
        return false;
      }
    }).toList();

    List<TimeOfDay> bookedTimes = [];

    bookings.forEach((element) {
      bookedTimes.add(element.time);
    });

    print(bookedTimes);
    print(slots);

    List<TimeOfDay> selectedSlots = slots;
    List<TimeOfDay> filtered = [];

    selectedSlots.forEach((element) {
      bool isBooked = false;
      bookedTimes.forEach((_element) {
        if (element.compareTo(_element) == 0) {
          isBooked = true;
        }
      });
      if (!isBooked) {
        filtered.add(element);
      }
    });

    return filtered;
  }

  static SessionBookings? upComingSession(List<SessionBookings> list) {
    List<SessionBookings> filter = list;

    filter = filter.where((element) {
      print(element.dateBooked);
      print('---');
      print(DateTime.now());
      var today = DateTime.now();
      if ((element.dateBooked.day == today.day &&
              element.dateBooked.year == today.year &&
              element.dateBooked.month == today.month) ||
          element.dateBooked.isAfter(today)) {
        return true;
      } else {
        return false;
      }
    }).toList();

    if (filter.isEmpty) {
      return null;
    }
    print('-xx-xxxxxxxxxxxxxxxxx');
    print(filter);

    filter = filter.where((element) {
      var today = DateTime.now();
      var timeOfDate = TimeOfDay.fromDateTime(today);

      if ((element.dateBooked.day == today.day &&
          element.dateBooked.year == today.year &&
          element.dateBooked.month == today.month)) {
        var x = element.time;
        if (x.compareTo(timeOfDate) == 1) {
          return true;
        }
        return false;
      } else {
        return true;
      }
    }).toList();
    if (filter.isEmpty) return null;
    return filter[0];
  }

  static discussionCategory(
      List<DiscussionCategories> categories, int categoryID) {
    return categories
        .where((element) => element.id == categoryID)
        .toList()[0]
        .category;
  }

  static SessionBookings? currentSession(List<SessionBookings> list) {}

  static TimeOfDay getSessionEndTime(TimeOfDay time, int slotSize) {
    return time.plusMinutes(slotSize);
  }


}

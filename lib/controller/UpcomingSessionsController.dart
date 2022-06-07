import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/constants.dart';

class UpcomingSessionsController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <SessionBookings>[].obs;
  var filter = <SessionBookings>[].obs;
  var error = "".obs;

  var todaySelected = false.obs;
  var paidSelected = false.obs;

  void filter_() {
    // if (todaySelected.isFalse && paidSelected.isFalse) {
    //   filter.value = results;
    // }

    List<SessionBookings> x = results.toList();

    if (todaySelected.isTrue) {
      x = x.where((element) {
        DateTime today = DateTime.now();
        DateTime withoutTime = DateTime(today.year, today.month, today.day);
        if (todaySelected.isTrue) {
          if (element.dateBooked.compareTo(withoutTime) == 0) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    if (paidSelected.isTrue) {
      x = x.where((element) => element.isPaid()).toList();
    }

    filter.value = x;
  }

  @override
  void onInit() async {
    print("call onInit"); // this line not printing
    // checkIsLogin();
    // print("ww");
    fetch(false);
    super.onInit();
  }

  Future<void> fetch(bool refresh) async {
    isLoading.value = true;
    error.value = "";

    var cache = box.read('upcoming_patient_sessions');
    if (refresh || cache == null) {
      var response = await supabase.rpc('upcoming_patient_sessions',
          params: {'user_id_param': supabase.auth.currentUser!.id}).execute();
      if (!response.hasError) {
        box.write('upcoming_patient_sessions', response.data);
        cache = response.data;
      }
    }

    isLoading.value = false;
    if (cache == null) {
      error.value = "Failed to fetch Upcoming sessions bookings";
    } else {
      results.value = sessionBookingsFromMap(cache);
      filter.value = results;
      filter_();
    }
  }
}

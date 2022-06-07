import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class CompletedSessionsController extends GetxController {
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

  Future<void> fetch(bool refresh) async {
    isLoading.value = true;
    error.value = "";

    var cache = box.read('completed_sessions_therapist');
    if (refresh || cache == null) {
      var response = await supabase.rpc('completed_sessions_therapist',
          params: {'user_id_param': supabase.auth.currentUser!.id}).execute();
      if (!response.hasError) {
        box.write('completed_sessions_therapist', response.data);
        cache = response.data;
      }
    }
    isLoading.value = false;

    if (cache == null) {
      error.value = "Failed to fetch histroy sessions";
    } else {
      results.value = sessionBookingsFromMap(cache);
      filter.value = results;
      filter_();
    }
  }
}

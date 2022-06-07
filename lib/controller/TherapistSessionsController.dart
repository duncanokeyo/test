import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/OngoingBookings.dart';
import 'package:bridgemetherapist/model/Questionnaire.dart';
import 'package:bridgemetherapist/model/TherapistSessions.dart';
import 'package:bridgemetherapist/model/Therpist.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class TherapistSessionController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <TherapistSessions>[].obs;
  var ongoingBookings = <OnGoingBookings>[].obs;
  var error = "".obs;
  var accurateDate;
  var accurateTime;
  var dateRange = <DateTime>[].obs;

  Future<void> fetch(bool refresh, String therapist_id) async {
    isLoading.value = true;
    error.value = "";

    var cache = null;
    //box.read('destination_reviews$destinationId');
    if (refresh || cache == null) {
      var bookedSessionsFetch = await supabase
          .from('session_bookings')
          .select('time,date_booked')
          .eq('therapist_id', therapist_id)
          .eq('is_cancelled', false)
          .eq('completed', false)
          .execute();

      if (bookedSessionsFetch.hasError) {
        isLoading.value = false;
        error.value = "Error occured";
        return;
      }

      ongoingBookings.value = ongoingBookingsFromMap(bookedSessionsFetch.data);

      var response = await supabase.rpc('get_therapist_sessions',
          params: {'therapist_id_param': therapist_id}).execute();

      isLoading.value = false;
      print(response.toJson());
      if (!response.hasError) {
        cache = response.data;
      } else {
        error.value = response.error!.message;
      }
      // Map<String, dynamic> results = cache;
    }
    print('cache is --------------------  ${cache}');
    if (error.isEmpty) {
      dateRange.value = Utils.getDaysInRangeList(results.toList());
      results.value = therapistSessionsFromMap(cache);
      accurateDate = results[0].accurateDate;
      accurateTime = results[0].accurateTime;
    }
  }
}

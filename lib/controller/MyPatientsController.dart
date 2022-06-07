import 'package:bridgemetherapist/model/Therpist.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class MyPatientsController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <Patient>[].obs;
  var error = "".obs;

  Future<void> fetch(bool refresh) async {
    isLoading.value = true;
    error.value = "";

    var cache = box.read('get_my_patients');
    if (refresh || cache == null) {
      var response = await supabase
          .rpc('get_my_patients', params: {
        'user_id_param': supabase.auth.currentUser!.id
      }).execute();

      print(response.toJson());
      if (!response.hasError) {
        box.write('get_my_patients', response.data);
        cache = response.data;
      }
    }
    isLoading.value = false;

    if (cache == null) {
      error.value = "Failed to fetch patient";
    } else {
      results.value = patientFromMap(cache);
    }
  }
}

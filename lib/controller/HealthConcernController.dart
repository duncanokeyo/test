import 'package:bridgemetherapist/model/HealthConcern.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class HealthConcernController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <HealthConcern>[].obs;
  var error = "".obs;

  HealthConcern ?selectedHealthConcern;

  Future<void> fetch(bool refresh) async {
    isLoading.value = true;
    error.value = "";

    var cache = box.read('health_concerns');
    if (refresh || cache == null) {
      var response =
          await supabase.from('health_concerns').select('*').execute();
      if (!response.hasError) {
        box.write('health_concerns', response.data);
        cache = response.data;
      }
    }
    isLoading.value = false;

    if (cache == null) {
      error.value = "Failed to fetch journals";
    } else {
      results.value = healthConcernFromMap(cache);
    }
  }
}

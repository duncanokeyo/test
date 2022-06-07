import 'package:bridgemetherapist/model/Journal.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class JournalController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <Journal>[].obs;
  var error = "".obs;

  Future<void> fetch(bool refresh) async {
    isLoading.value = true;
    error.value = "";

    var cache = box.read('journals');
    if (refresh || cache == null) {
      var response = await supabase
          .from('journals')
          .select('*')
          .eq('user_id', supabase.auth.currentUser!.id)
          .execute();
      if (!response.hasError) {
        box.write('journals', response.data);
        cache = response.data;
      }
    }
    isLoading.value = false;

    if (cache == null) {
      error.value = "Failed to fetch journals";
    } else {
      results.value = journalFromMap(cache);
    }
  }
}

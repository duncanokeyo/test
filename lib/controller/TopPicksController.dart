import 'package:bridgemetherapist/model/TopPicks.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class TopPicksController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <TopPicks>[].obs;
  var error = "".obs;

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

    print('------------------------fetching top picks ---------------------- ');
    var cache = box.read('top_picks');
    if (refresh || cache == null) {
      var response = await supabase.rpc('get_top_picks').execute();
      if (!response.hasError) {
        box.write('top_picks', response.data);
        cache = response.data;
      }
    }
    print('--------------------done fetching top picks ----------------------');
    isLoading.value = false;

    if (cache == null) {
      error.value = "Failed to fetch journals";
    } else {
      results.value = topPicksFromMap(cache);
    }
  }
}

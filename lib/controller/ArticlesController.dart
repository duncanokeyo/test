
import 'package:bridgemetherapist/model/Articles.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ArticlesController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <Articles>[].obs;
  var error = "".obs;

    RefreshController refreshController =
      RefreshController(initialRefresh: false);


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

    var cache = box.read('articles');
    print(" ----------------------- fetcing articles------------------------------");
    if (refresh || cache == null) {
      var response = await supabase.rpc('get_articles').execute();
      if (!response.hasError) {
        box.write('articles', response.data);
        cache = response.data;
      }
    }
    print(" ----------------------- done fetcing articles------------------------------");


    isLoading.value = false;

    if (cache == null) {
      error.value = "Failed to fetch Articles picks";
    } else {
      results.value = articlesFromMap(cache);
    }
  }
}

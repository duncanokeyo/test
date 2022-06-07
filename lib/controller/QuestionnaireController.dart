import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/model/Questionnaire.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class QuestionnaireController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  var results = <Questionnaire>[].obs;
  var error = "".obs;

  Future<void> fetch(bool refresh) async {
    isLoading.value = true;
    error.value = "";

    var cache = null;
    //box.read('destination_reviews$destinationId');
    // CHECK IF I HAVE ALREADY ANSWERED THE QUESTIONS
    var isAnsweredFetch = await supabase
        .from('questionnaire_answers')
        .select('*')
        .eq('user_id', supabase.auth.currentUser!.id)
        .execute();
    if (isAnsweredFetch.hasError) {
      isLoading.value = false;
      error.value = "Error occured";
      return;
    } else {
      if ((isAnsweredFetch.data as List<dynamic>).isNotEmpty) {
        isLoading.value = false;
        error.value = "";
        Get.find<GetStorage>().write('skip_questionnaire', true);
        Navigator.of(NavigationService.navigatorKey.currentState!.context)
            .pushNamedAndRemoveUntil(Routes.home, (route) => false);
      }
    }
    
    if (refresh || cache == null) {
      var response = await supabase.rpc('get_my_questionnaire',
          params: {'user_id_param': supabase.auth.currentUser!.id}).execute();

      isLoading.value = false;

      if (!response.hasError) {
        cache = response.data;
      } else {
        error.value = response.error!.message;
      }
    } // Map<String, dynamic> results = cache;

    print('cache is --------------------  ${cache}');
    if (error.isEmpty) {
      results.value = questionnaireFromMap(cache);
    }
  }

  void save(Map<Questionnaire, int> selectedOptions) {
    box.write('skip_questionnaire', true);
    isLoading.value = true;
    //todo save
    Navigator.pushNamedAndRemoveUntil(
      NavigationService.navigatorKey.currentContext!,
      Routes.home,
      (route) => false,
    );
  }
}

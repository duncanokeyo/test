import 'package:bridgemetherapist/controller/PatientsSeenController.dart';
import 'package:bridgemetherapist/controller/UpcomingSessionsController.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class PresetsController extends GetxController {
  final box = Get.find<GetStorage>();
  var isLoading = false.obs;
  var error = "".obs;

  bool isPresetsLoaded() {
    return box.read('profile') != null &&
        box.read('discussion_categories') != null;
  }

  Future<void> fetch(
      bool loadProfile, bool loadMpesa, bool loadDiscussionCategories) async {
    //Get.find<UpcomingSessionsController>().fetch(true);
    //Get.find<PatientsSeenController>().fetch(true);
    isLoading.value = true;
    error.value = "";

    if (loadProfile) {
      var response = await supabase
          .from('profiles')
          .select(
              "id,username,created_at,gender,avatar_url,phone_number,location,about,email")
          .eq("id", supabase.auth.currentUser?.id)
          .execute();

      print(response.toJson());
      
      if (response.hasError == false) {
        box.write('profile', response.data);
      } else {
        isLoading.value = false;
        error.value = "Error occured";
        return;
      }
    }

    if (loadDiscussionCategories) {
      var response =
          await supabase.from('discussion_categories').select("*").execute();
      if (response.hasError == false) {
        box.write('discussion_categories', response.data);
      } else {
        isLoading.value = false;
        error.value = "Error occured";
        return;
      }
    }

    // if (loadMpesa) {
    //   var response = await supabase
    //       .from('mpesa_credentials')
    //       .select("consumer_key,consumer_secret,passphrase,call_back,paybill")
    //       .execute();
    //   print(response.toJson());
    //   if (response.hasError == false) {
    //     box.write('mpesa_credentials', response.data);
    //   } else {
    //     isLoading.value = false;
    //     error.value = "Error occured";
    //     return;
    //   }
    // }

    isLoading.value = false;
    error.value = "";
  }
}

import 'package:bridgemetherapist/model/ScreeningTools.dart';
import 'package:bridgemetherapist/model/ScreeningToolsSessionBooking.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreeningToolsController extends GetxController {
  final box = Get.find<GetStorage>();

  var isLoading = false.obs;
  //var results = <ScreeningTools>[].obs;
  var results = <QuestionnaireAnswerCountFlatten>[].obs;
  var sessionBookings = <ScreeningToolsSessionBooking>[];
  var patientId_;

  var error = "".obs;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  Future<void> fetch(bool refresh, String patientId, String therapistId) async {
    isLoading.value = true;
    error.value = "";

    var cache = box.read('screening_tools$patientId');

    if (sessionBookings.isEmpty || patientId_ != patientId) {
      var screeningToolsSessionBookingFetch = await supabase
          .rpc('screening_tools_session_bookings', params: {
        'therapist_id_param': therapistId,
        'patient_id_param': patientId
      }).execute();

      if (screeningToolsSessionBookingFetch.hasError) {
        isLoading.value = false;
        error.value = "Error fetching session bookings";
        return;
      }

      sessionBookings = screeningToolsSessionBookingFromMap(
          screeningToolsSessionBookingFetch.data);
    }
    patientId_ = patientId;

    if (refresh || cache == null) {
      var response = await supabase.rpc('get_screening_tools_rpc', params: {
        'patient_id_param': patientId,
        'therapist_id_param': therapistId
      }).execute();
      if (!response.hasError) {
        box.write('screening_tools$patientId', response.data);
        cache = response.data;
      }
    }

    isLoading.value = false;

    if (cache == null) {
      error.value = "Failed to fetch screening tools";
      results.value = [];
    } else {
      List<ScreeningTools> tools = screeningToolsFromJson(cache);
      List<QuestionnaireAnswerCountFlatten> flatten = [];
      for (var element in tools) {
        for (var element_ in element.questionnaireAnswerCount) {
          QuestionnaireAnswerCountFlatten flattenned =
              QuestionnaireAnswerCountFlatten(
                  questionnaireAnswerCount: element_,
                  questionnaireTypeId: element.questionnaireTypeId,
                  questionnaireTitle: element.questionnaireTitle,
                  hideQuestionnaire: element.hideQuestionnaire,
                  questionnaireQuestionCount:
                      element.questionnaireQuestionCount);

          flatten.add(flattenned);
        }
      }
      results.value = flatten;
      //results.value = screeningToolsFromJson(cache);
    }
  }
}

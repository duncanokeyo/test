import 'dart:collection';
import 'dart:convert';

import 'package:bridgemetherapist/controller/ScreeningToolsController.dart';
import 'package:bridgemetherapist/model/ScreeningTools.dart';
import 'package:bridgemetherapist/pages/screeningtools/administer_new_questionnaire.dart';
import 'package:bridgemetherapist/pages/screeningtools/view_screening_results.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class ScreeningToolsList extends StatefulWidget {
  String patientId;
  String therapistId;
  String patientName;

  String therapistAvatarUrl;
  String patientAvatarUrl;
  String therapistName;

  ScreeningToolsList(
      {required this.patientId,
      required this.therapistName,
      required this.patientAvatarUrl,
      required this.therapistAvatarUrl,
      required this.therapistId,
      required this.patientName});

  @override
  State<StatefulWidget> createState() {
    return ScreeningToolsListState();
  }
}

class ScreeningToolsListState extends State<ScreeningToolsList> {
  ScreeningToolsController controller = Get.find();
  final searchController = TextEditingController();

  @override
  void initState() {
    controller.fetch(false, widget.patientId, widget.therapistId);
    searchController.addListener(_search);
    super.initState();
  }

  _search() {
    String text = searchController.text;
    controller.search(text);
  }

  void _viewResults(BuildContext context,
      QuestionnaireAnswerCountFlatten questionnaireAnswerCountFlatten) {
    var inputLink = controller.linkTemplates[0].screeningToolResults;
    inputLink = inputLink!
        .replaceAll("{therapist_id}", widget.therapistId)
        .replaceAll("{patient_id}", widget.patientId)
        .replaceAll("{question_id}",
            questionnaireAnswerCountFlatten!.questionnaireTypeId.toString())
        .replaceAll(
            "{session_id}",
            questionnaireAnswerCountFlatten
                .questionnaireAnswerCount.sessionBookingId
                .toString());

    print(inputLink);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewQuestionnaireResults(
          initialUrl: inputLink!,
        ),
      ),
    );
  }

  Future<void> _readministerScreeningTool(BuildContext context,
      QuestionnaireAnswerCountFlatten questionnaireAnswerCountFlatten) async {
    var inputLink = controller.linkTemplates[0].screeningToolInput;
    var message =
        'Hello ${widget.patientName}, please click on the link below to answer screening tool \n\n$inputLink';

    message = message
        .replaceAll("{therapist_id}", widget.therapistId)
        .replaceAll("{patient_id}", widget.patientId)
        .replaceAll("{question_id}",
            questionnaireAnswerCountFlatten!.questionnaireTypeId.toString())
        .replaceAll(
            "{session_id}",
            questionnaireAnswerCountFlatten
                .questionnaireAnswerCount.sessionBookingId
                .toString());

    Map<String, dynamic> data = HashMap();
    Map<String, dynamic> notificaiton = HashMap();
    data["to"] = "/topics/${widget.patientId}";
    notificaiton["title"] = "Screening tool";
    notificaiton["body"] = message;
    data["notification"] = notificaiton;
    data["data"] = {
      'type':'screening-tool-readminister'
    };

    ProgressDialog pd = ProgressDialog(context: context);

    pd.show(max: 100, msg: 'Re-administering screening tool');


    var screeningToolsActions =
        await supabase.rpc('screening_tools_actions_rpc', params: {
      'send_notification_param': true,
      'send_message_only_param': true,
      'client_message_param': jsonEncode(data),
      'session_booking_id_param': questionnaireAnswerCountFlatten
          .questionnaireAnswerCount.sessionBookingId,
      'therapist_id_param': widget.therapistId,
      'patient_id_param': widget.patientId,
      'questionnaire_test_answers_id_param': questionnaireAnswerCountFlatten
          .questionnaireAnswerCount.questionAnswerId,
      'questionnaire_type_id_param':
          questionnaireAnswerCountFlatten.questionnaireTypeId,
      'therapist_name_param': widget.therapistName,
      'patient_name_param': widget.patientName,
      'therapist_avatar_url_param': widget.therapistAvatarUrl,
      'patient_avatar_url_param': widget.patientAvatarUrl,
      'message_param': message,
      'message_type_param': 'text',
      'last_message_type_param': 'text',
      'is_delete_action_param': false
    }).execute();

    if (pd.isOpen()) {
      pd.close();
    }

    if (screeningToolsActions.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error re-administering patient screening tool")));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kColorDarkGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdministerNewQuestionnaire(
                patientId: widget.patientId,
                therapistId: widget.therapistId,
                patientName: widget.patientName,
                sessionBookings: controller.sessionBookings,
                linkTemplates: controller.linkTemplates,
                screeningTools: controller.screeningTools,
                patientAvatarUrl: widget.patientAvatarUrl,
                therapistAvatarUrl: widget.therapistAvatarUrl,
                therapistName: widget.therapistName,
              ),
            ),
          ).then((value) {
            controller.fetch(true, widget.patientId, widget.therapistId);
          });
          //}
        },
        icon: const Icon(Icons.add),
        label: const Text("Administer new screening tool"),
      ),
      appBar: AppBar(
        toolbarHeight: 150,
        title: Column(
          children: [
            const Text('Administered screening tools'),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: kColorGreen, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide:
                        BorderSide(color: Colors.grey[300]!, width: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey[250],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  hintText: 'Search administered screening tools',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
                cursorWidth: 1,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () {
          if (controller.isLoading.isTrue) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isNotEmpty) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InkWell(
                onTap: () {
                  controller.fetch(true, widget.patientId, widget.therapistId);
                },
                child: const Center(
                  child: Text(
                      "Error fetching administered screening tools, tap to refresh"),
                ),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isEmpty &&
              controller.results.isEmpty) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InkWell(
                onTap: () {
                  controller.fetch(true, widget.patientId, widget.therapistId);
                },
                child: const Center(
                  child: Text("No administered screening tools"),
                ),
              ),
            );
          } else {
            return SmartRefresher(
              controller: controller.refreshController,
              enablePullDown: true,
              enablePullUp: false,
              onRefresh: () {
                controller.fetch(true, widget.patientId, widget.therapistId);
                controller.refreshController.refreshCompleted();
              },
              child: Padding(
                padding: kIsWeb
                    ? const EdgeInsets.only(
                        left: WEBPADDING, right: WEBPADDING, top: 20)
                    : const EdgeInsets.only(top: 5),
                child: SingleChildScrollView(
                    child: Column(
                  children: List.generate(controller.filter.length, (index) {
                    QuestionnaireAnswerCountFlatten
                        questionnaireAnswerCountFlatten =
                        controller.filter[index];
                    return getCard(context, questionnaireAnswerCountFlatten);
                  }),
                )),
              ),
            );
          }
        },
      ),
    );
  }

  Widget getAnsweredText(
      QuestionnaireAnswerCountFlatten questionnaireAnswerCountFlatten) {
    if (questionnaireAnswerCountFlatten.questionnaireAnswerCount.answerCount ==
        0) {
      return Text(
        "Not answered",
        style: TextStyle(
            color: Colors.red[500],
            fontFamily: "Product_Sans_Regular",
            fontSize: 10.0,
            height: 1.4),
      );
    }

    if (questionnaireAnswerCountFlatten.questionnaireQuestionCount <
        questionnaireAnswerCountFlatten.questionnaireAnswerCount.answerCount) {
      return const Text(
        "Partially answered",
        style: TextStyle(
            color: Colors.blue,
            fontFamily: "Product_Sans_Regular",
            fontSize: 10.0,
            height: 1.4),
      );
    } else if (questionnaireAnswerCountFlatten.questionnaireQuestionCount ==
        questionnaireAnswerCountFlatten.questionnaireAnswerCount.answerCount) {
      return const Text(
        "Answered",
        style: TextStyle(
            color: Colors.green,
            fontFamily: "Product_Sans_Regular",
            fontSize: 10.0,
            height: 1.4),
      );
    }

    return const Text(
      " ",
      style: TextStyle(
          color: Colors.blue,
          fontFamily: "Product_Sans_Regular",
          fontSize: 10.0,
          height: 1.4),
    );
  }

  Widget getCard(BuildContext context,
      QuestionnaireAnswerCountFlatten questionnaireAnswerCountFlatten) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Card(
        child: ListTile(
            visualDensity: const VisualDensity(vertical: 1), // to expand
            isThreeLine: true,
            title: Text(questionnaireAnswerCountFlatten.questionnaireAnswerCount
                .sessionTitle()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  questionnaireAnswerCountFlatten.questionnaireTitle,
                  style: const TextStyle(
                      color: Color(0xff2e66e7),
                      fontFamily: "Product_Sans_Regular",
                      fontSize: 10.0,
                      height: 1.4),
                ),
                const SizedBox(
                  height: 4,
                ),
                getAnsweredText(questionnaireAnswerCountFlatten)
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) {
                return [
                  if (questionnaireAnswerCountFlatten
                          .questionnaireAnswerCount.answerCount >
                      0) ...[
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('view'),
                    ),
                  ],
                  if (questionnaireAnswerCountFlatten
                          .questionnaireAnswerCount.answerCount !=
                      questionnaireAnswerCountFlatten
                          .questionnaireQuestionCount) ...[
                    const PopupMenuItem(
                      value: 're-administer',
                      child: Text('Re-administer'),
                    )
                  ]
                ];
              },
              onSelected: (String value) {
                if (value == 'view') {
                  _viewResults(context, questionnaireAnswerCountFlatten);
                } else if (value == 're-administer') {
                  _readministerScreeningTool(
                      context, questionnaireAnswerCountFlatten);
                }
              },
            )),
      ),
    );
  }
}

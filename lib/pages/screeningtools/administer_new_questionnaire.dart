import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/components/custom_button.dart';
import 'package:bridgemetherapist/model/LinkTemplate.dart';
import 'package:bridgemetherapist/model/ScreeningTools.dart';
import 'package:bridgemetherapist/model/ScreeningToolsSessionBooking.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get_navigation/src/extension_navigation.dart';

class AdministerNewQuestionnaire extends StatefulWidget {
  String patientId;
  String therapistId;
  String patientName;
  String therapistAvatarUrl;
  String patientAvatarUrl;
  String therapistName;
  List<ScreeningToolsSessionBooking> sessionBookings =
      <ScreeningToolsSessionBooking>[];
  List<ScreeningTools> screeningTools = <ScreeningTools>[];

  List<LinkTemplate> linkTemplates = <LinkTemplate>[];
  AdministerNewQuestionnaire(
      {Key? key,
      required this.patientId,
      required this.sessionBookings,
      required this.screeningTools,
      required this.therapistId,
      required this.therapistAvatarUrl,
      required this.patientAvatarUrl,
      required this.therapistName,
      required this.linkTemplates,
      required this.patientName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AdministerNewQuestionnaireState();
  }
}

class AdministerNewQuestionnaireState
    extends State<AdministerNewQuestionnaire> {
  ScreeningToolsSessionBooking? _selectedBooking;
  ScreeningTools? _selectedScreeningTool;
  final TextEditingController _clientMessageController =
      TextEditingController();

  var _processing = false;

  @override
  void initState() {
    super.initState();
    var inputLink = widget.linkTemplates[0].screeningToolInput;

    _clientMessageController.text =
        'Hello ${widget.patientName}, please click on the link below to answer screening tool \n\n$inputLink';
    super.initState();
  }

  Future<void> _administerQuestionnaire(BuildContext context) async {
    String message = _clientMessageController.text;
    var inputLink = widget.linkTemplates[0].screeningToolInput;

    if (_selectedScreeningTool == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select screening tool")));
      return;
    }
    if (_selectedBooking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select session booking")));
      return;
    }
    if (message.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter client message")));
      return;
    }

    if (!message.trim().endsWith(inputLink!)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "ERROR",
              style: TextStyle(color: Colors.red),
            ),
            content: const Text(
                "Link to the screening tool must be included at the end of the message."),
            actions: [
              TextButton(
                  onPressed: () {
                    String message = _clientMessageController.text +
                        "\n" +
                        widget.linkTemplates[0].screeningToolInput!;
                    _clientMessageController.text = message;

                    Navigator.of(context).pop();
                  },
                  child: const Text("Insert link"))
            ],
          );
        },
      );

      return;
    }

    message = message
        .replaceAll("{therapist_id}", widget.therapistId)
        .replaceAll("{patient_id}", widget.patientId)
        .replaceAll("{question_id}",
            _selectedScreeningTool!.questionnaireTypeId.toString())
        .replaceAll("{session_id}", _selectedBooking!.id.toString());

    setState(() {
      _processing = true;
    });

    Map<String, dynamic> data = HashMap();
    Map<String, dynamic> notificaiton = HashMap();
    data["to"] = "/topics/${widget.patientId}";
    notificaiton["title"] = "Screening tool";
    notificaiton["body"] = message;
    data["notification"] = notificaiton;

    data["data"] = {'type': 'screening-tool-administer'};

    var screeningToolsActions =
        await supabase.rpc('screening_tools_actions_rpc', params: {
      'send_notification_param': true,
      'send_message_only_param': false,
      'client_message_param': jsonEncode(data),
      'session_booking_id_param': _selectedBooking!.id,
      'therapist_id_param': widget.therapistId,
      'patient_id_param': widget.patientId,
      'questionnaire_test_answers_id_param':
          _selectedScreeningTool!.questionnaireTypeId,
      'questionnaire_type_id_param':
          _selectedScreeningTool!.questionnaireTypeId,
      'therapist_name_param': widget.therapistName,
      'patient_name_param': widget.patientName,
      'therapist_avatar_url_param': widget.therapistAvatarUrl,
      'patient_avatar_url_param': widget.patientAvatarUrl,
      'message_param': message,
      'message_type_param': 'text',
      'last_message_type_param': 'text',
      'is_delete_action_param': false
    }).execute();

    setState(() {
      _processing = false;
    });

    if (screeningToolsActions.hasError) {
      print(screeningToolsActions.error);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error administering patient screening tool")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Successfully administered screening tool")));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Administer new Screening tool'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: kIsWeb
                ? const EdgeInsets.only(left: WEBPADDING, right: WEBPADDING)
                : const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Card(
                  child: InkWell(
                    onTap: () async {
                      await FilterListDelegate.show<
                          ScreeningToolsSessionBooking>(
                        context: context,
                        list: widget.sessionBookings,
                        enableOnlySingleSelection: true,
                        onItemSearch: (item, query) {
                          String title = "Session @ " +
                              Utils.humanReadableDate(item.dateBooked) +
                              " " +
                              Utils.humanReadableTimeOfDay(item.timeBooked);
                          return title
                              .toLowerCase()
                              .contains(query.toLowerCase());
                        },
                        tileLabel: (item) => item == null
                            ? ""
                            : "Session @ " +
                                Utils.humanReadableDate(item.dateBooked) +
                                " " +
                                Utils.humanReadableTimeOfDay(item.timeBooked),
                        emptySearchChild:
                            const Center(child: Text('No session found')),
                        searchFieldHint: 'Search Here..',
                        onApplyButtonClick: (list) {
                          if (list != null) {
                            setState(() {
                              _selectedBooking = list[0];
                            });
                          }
                          // Do something with selected list
                        },
                      );
                    },
                    child: ListTile(
                      trailing: const Icon(Icons.arrow_forward_ios),
                      title: _selectedBooking == null
                          ? const Text("Tap to select session")
                          : Text("Session @ " +
                              Utils.humanReadableDate(
                                  _selectedBooking!.dateBooked) +
                              " " +
                              Utils.humanReadableTimeOfDay(
                                  _selectedBooking!.timeBooked)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  child: InkWell(
                    onTap: () async {
                      await FilterListDelegate.show<ScreeningTools>(
                        context: context,
                        list: widget.screeningTools,
                        enableOnlySingleSelection: true,
                        onItemSearch: (item, query) {
                          return item.questionnaireTitle
                              .toLowerCase()
                              .contains(query.toLowerCase());
                        },
                        tileLabel: (item) =>
                            item == null ? "" : item.questionnaireTitle,
                        emptySearchChild: const Center(
                            child: Text('No screening tools found')),
                        searchFieldHint: 'Search Here..',
                        onApplyButtonClick: (list) {
                          if (list != null) {
                            setState(() {
                              _selectedScreeningTool = list[0];
                            });
                          }
                          // Do something with selected list
                        },
                      );
                    },
                    child: ListTile(
                      trailing: const Icon(Icons.arrow_forward_ios),
                      title: _selectedScreeningTool == null
                          ? const Text("Tap to select screening tool")
                          : Text(_selectedScreeningTool!.questionnaireTitle),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _clientMessageController,
                  validator: (String? val) {
                    // if (val == null) {
                    //   return 'This field is required';
                    // }
                    // if (val.isEmpty) {
                    //   return 'This field is required';
                    // }

                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: 100,
                  minLines: 10,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: kColorDarkGreen, width: 1.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: kColorDarkGreen, width: 1.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: kColorDarkGreen),
                    labelStyle: TextStyle(color: kColorDarkGreen),
                    labelText: "Patient message template",
                    fillColor: Colors.white70,
                    alignLabelWithHint: true,
                    isDense: true,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                if (_selectedBooking != null &&
                    _selectedScreeningTool != null) ...[
                  if (_processing) ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kColorDarkGreen),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: CustomButton(
                        onPressed: () {
                          _administerQuestionnaire(context);
                        },
                        text: 'Administer screening tool',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ]
                ]
              ],
            ),
          ),
        ));
  }
}

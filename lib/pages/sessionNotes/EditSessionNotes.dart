import 'dart:collection';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/SessionNote.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditSessionNotes extends StatefulWidget {
  var patientId;
  DateTime date;
  TimeOfDay time;
  EditSessionNotes(
      {required this.patientId, required this.time, required this.date});

  @override
  State<StatefulWidget> createState() {
    return _EditSessionNotesSate();
  }
}

class _EditSessionNotesSate extends State<EditSessionNotes> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  var isFetching = false;
  var errorFetching = false;
  var sessionNote;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetch();
  }

  _fetch() async {
    setState(() {
      isFetching = true;
      errorFetching = false;
    });

    var response = await supabase
        .from('session_notes')
        .select("*")
        .eq("therapist_id", supabase.auth.currentUser!.id)
        .eq("patient_id", widget.patientId)
        .eq('date_booked', Utils.getParamTimeFormat(widget.date))
        .eq('time_booked', Utils.getTimeOfDayParam(widget.time))
        .execute();
    if (response.hasError) {
      setState(() {
        isFetching = false;
        errorFetching = false;
      });
      return;
    }

    List<SessionNote> notes = sessionNotesFromMap(response.data);

    if (notes.isNotEmpty) {
      sessionNote = notes[0];
    }
    setState(() {
      if (sessionNote != null) {
        titleController.text = (sessionNote as SessionNote).title;
        bodyController.text = (sessionNote as SessionNote).content;
      }
      isFetching = false;
      errorFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Session Note",
          style: TextStyle(
            color: kColorDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: size.height,
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Column(children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     IconButton(
            //       icon: Icon(Icons.arrow_back_ios),
            //       onPressed: () {
            //         Navigator.pop(context);
            //       },
            //     ),
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width / 4,
            //     ),
            //     const Text(
            //       "Session Notes",
            //       style: TextStyle(
            //         fontSize: 24,
            //         color: kColorDarkGreen,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(
              height: 20,
            ),
            if (isFetching) ...[
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (!isFetching && errorFetching) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () {
                    _fetch();
                  },
                  child: Center(
                    child: const Text(
                        "Error fetching session notes tap to refresh"),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                padding:kIsWeb?const EdgeInsets.only(left: WEBPADDING,right: WEBPADDING) :const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          maxLines: null,
                          autofocus: true,
                          controller: titleController,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Title",
                          ),
                          style: const TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: bodyController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 200,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration.collapsed(
                            hintText: "Type something...",
                          ),
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kColorDarkGreen,
        onPressed: () async {
          if (titleController.text.length == 0 &&
              bodyController.text.length == 0) {
            showEmptyTitleDialog(context);
          } else {
            // if (titleController.text.length == 0) {
            //   ScaffoldMessenger.of(context)
            //       .showSnackBar(SnackBar(content: Text("Set title")));
            //   return;
            // }
            if (bodyController.text.length == 0) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Set content")));
              return;
            }

            ProgressDialog pd = ProgressDialog(context: context);
            pd.show(max: 100, msg: 'Saving session note');

            Map<String, String> insert = new HashMap();
            insert["title"] = titleController.text;
            insert["content"] = bodyController.text;
            insert["therapist_id"] = supabase.auth.currentUser!.id;
            insert["patient_id"] = widget.patientId;
            if (sessionNote != null) {
              insert["id"] = (sessionNote as SessionNote).id.toString();
            }

            var response =
                await supabase.from('session_notes').upsert(insert).execute();
            pd.close();

            if (response.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error saving session note")));
              return;
            }
            Navigator.of(context).pop();
          }
        },
        label: Text("Save"),
        icon: Icon(Icons.save),
      ),
    );
  }
}

void showEmptyTitleDialog(BuildContext context) {
  print("in dialog ");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        title: Text(
          "Notes is empty!",
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          'The content of the note cannot be empty to be saved.',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Okay",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

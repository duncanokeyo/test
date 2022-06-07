import 'dart:collection';


import 'package:bridgemetherapist/controller/JournalController.dart';
import 'package:bridgemetherapist/model/Journal.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class ShowJournal extends StatelessWidget {
  final Journal journal;
  final int index;
  ShowJournal({required this.journal, required this.index});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = journal.title!;
    bodyController.text = journal.content;
    var formattedDate = DateFormat.yMMMd().format(journal.createdAt);
    var time = DateFormat.jm().format(journal.createdAt);
    return Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(
              16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDeleteDialog(context, journal, () async {
                          ProgressDialog pd = ProgressDialog(context: context);
                          pd.show(max: 100, msg: 'Delete journal');

                          var response = await supabase
                              .from('journals')
                              .delete()
                              .eq('id', journal.id)
                              .execute();
                          pd.close();

                          if (response.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Error deleting journal")));
                            return;
                          }

                          Get.find<JournalController>().fetch(true);
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text("$formattedDate at $time"),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: titleController,
                          maxLines: null,
                          decoration: InputDecoration.collapsed(
                            hintText: "Title",
                          ),
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          autofocus: true,
                          controller: bodyController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 200,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Type something...",
                          ),
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: kColorDarkGreen,
          onPressed: () async {
            if (titleController.text != journal.title ||
                bodyController.text != journal.content) {
              //  Database().updateNote(authController.user.uid,
              //    titleController.text, bodyController.text, noteData.id);
              // Get.back();

              if (titleController.text.length == 0) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Set title")));
                return;
              }
              if (bodyController.text.length == 0) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Set content")));
                return;
              }

              ProgressDialog pd = ProgressDialog(context: context);
              pd.show(max: 100, msg: 'Updating journal');

              Map<String, String> insert = new HashMap();
              insert["title"] = titleController.text;
              insert["content"] = bodyController.text;

              var response = await supabase
                  .from('journals')
                  .update(insert)
                  .eq('id', journal.id)
                  .execute();
              pd.close();

              if (response.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error updating journal")));
                return;
              }

              titleController.clear();
              bodyController.clear();

              Get.find<JournalController>().fetch(true);
              Navigator.of(context).pop();
            } else {
              showSameContentDialog(context);
            }
          },
          label: Text("Save"),
          icon: Icon(Icons.save),
        ));
  }
}

void showDeleteDialog(
    BuildContext context, Journal journal, Function onDeletePressed) {
  //final AuthController authController = Get.find<AuthController>();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
          "Delete journal?",
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text("Are you sure you want to delete this journal?",
            style: Theme.of(context).textTheme.subtitle1),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Yes",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              onDeletePressed();
            },
          ),
          TextButton(
            child: Text(
              "No",
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

void showSameContentDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
          "No change in content!",
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text("There is no change in content.",
            style: Theme.of(context).textTheme.subtitle1),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Okay",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      );
    },
  );
}

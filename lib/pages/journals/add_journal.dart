import 'dart:collection';

import 'package:bridgemetherapist/controller/JournalController.dart';
import 'package:bridgemetherapist/model/SessionNote.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class AddJournalPage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Journal",
          style: TextStyle(
            
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: size.height,
          padding: EdgeInsets.all(
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
            //     Text(
            //       "Journal",
            //       style: TextStyle(
            //         fontSize: 24,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: kIsWeb
                      ? EdgeInsets.only(left: WEBPADDING, right: WEBPADDING)
                      : const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        maxLines: null,
                        autofocus: true,
                        controller: titleController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration.collapsed(
                          hintText: "Title",
                        ),
                        style: TextStyle(
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
            pd.show(max: 100, msg: 'Saving journal');

            Map<String, String> insert = new HashMap();
            insert["title"] = titleController.text;
            insert["content"] = bodyController.text;
            insert["user_id"] = supabase.auth.currentUser!.id;

            var response =
                await supabase.from('journals').insert(insert).execute();
            pd.close();

            if (response.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error saving journal")));
              return;
            }

            Get.find<JournalController>().fetch(true);
            Navigator.of(context).pop();

            // Database().addNote(authController.user.uid, titleController.text,
            //   bodyController.text);
            //Get.back();
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

import 'dart:collection';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/SessionNotesSessionBooking.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class AddSessionNotes extends StatefulWidget {
  var patientId;
  // DateTime dateBooked;
  //TimeOfDay timeBooked;
  AddSessionNotes({
    Key? key,
    required this.patientId,
    //   required this.dateBooked,
    //required this.timeBooked
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddSessionNotesSate();
  }
}

class _AddSessionNotesSate extends State<AddSessionNotes> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  var _sessionBookings = <SessionNoteSessionBooking>[];

  var _fetchingBookings = false;
  var _errorFetchingBookings = false;
  SessionNoteSessionBooking? _selectedBooking;

  @override
  void initState() {
    super.initState();

    _fetch();
  }

  _fetch() async {
    setState(() {
      _fetchingBookings = true;
      _errorFetchingBookings = false;
    });

    var response =
        await supabase.rpc('session_notes_session_bookings', params: {
      'therapist_id_param': supabase.auth.currentUser!.id,
      'user_id_param': widget.patientId
    }).execute();

    if (response.hasError) {
      setState(() {
        _errorFetchingBookings = true;
        _fetchingBookings = false;
      });
      return;
    }

    setState(() {
      _errorFetchingBookings = false;
      _fetchingBookings = false;
      _sessionBookings = sessionNoteSessionBookingFromMap(response.data);
    });
  }

  // Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         IconButton(
  //                           icon: Icon(Icons.arrow_back_ios),
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                         SizedBox(
  //                           width: MediaQuery.of(context).size.width / 4,
  //                         ),
  //                         const Text(
  //                           "Session Notes",
  //                           style: TextStyle(
  //                             fontSize: 24,
  //                             color: kColorDarkGreen,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Session Notes",
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
          child: _fetchingBookings
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _errorFetchingBookings
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: InkWell(
                        onTap: () {
                          _fetch();
                        },
                        child: Center(
                          child: const Text(
                              "Error fetching sessions. Tap to refresh"),
                        ),
                      ),
                    )
                  : Padding(
                    padding: kIsWeb?EdgeInsets.only(left: WEBPADDING,right: WEBPADDING):const EdgeInsets.all(8.0),
                    child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          
                          Card(
                            child: InkWell(
                              onTap: () async {
                                await FilterListDelegate.show<SessionNoteSessionBooking>(
                                  context: context,
                                  list: _sessionBookings,
                                  enableOnlySingleSelection: true,
                                  onItemSearch: (item, query) {
                                    String title = "Session @ " +
                                        Utils.humanReadableDate(item.dateBooked) +
                                        " " +
                                        Utils.humanReadableTimeOfDay(
                                            item.timeBooked);
                                    return title
                                        .toLowerCase()
                                        .contains(query.toLowerCase());
                                  },
                                  tileLabel: (item) => item == null
                                      ? ""
                                      : "Session @ " +
                                          Utils.humanReadableDate(
                                              item.dateBooked) +
                                          " " +
                                          Utils.humanReadableTimeOfDay(
                                              item.timeBooked),
                                  emptySearchChild:
                                      Center(child: Text('No session found')),
                                  searchFieldHint: 'Search Here..',
                                  onApplyButtonClick: (list) {
                                    print(list);
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
                                trailing: Icon(Icons.arrow_forward_ios),
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

                          SizedBox(height: 25,),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextFormField(
                                    maxLines: null,
                                    autofocus: true,
                                    controller: titleController,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: const InputDecoration.collapsed(
                                      hintText: "Title",
                                    ),
                                    style: const TextStyle(
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: bodyController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    minLines: 200,
                                    textCapitalization:
                                        TextCapitalization.sentences,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kColorDarkGreen,
        onPressed: () async {
          if (bodyController.text.isEmpty) {
            showEmptyTitleDialog(context);
          } else {
            if (bodyController.text.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Set content")));
              return;
            }

            if (_selectedBooking == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Select session")));
              return;
            }

            ProgressDialog pd = ProgressDialog(context: context);
            pd.show(max: 100, msg: 'Saving session note');

            Map<String, String> insert = new HashMap();
            insert["title"] = titleController.text;
            insert["content"] = bodyController.text;
            insert["therapist_id"] = supabase.auth.currentUser!.id;
            insert["patient_id"] = widget.patientId;
            insert["date_booked"] =
                Utils.getParamTimeFormat(_selectedBooking!.dateBooked);
            insert['time_booked'] =
                Utils.getTimeOfDayParam(_selectedBooking!.timeBooked);

            var response =
                await supabase.from('session_notes').insert(insert).execute();
            pd.close();

            if (response.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error saving session note")));
              return;
            }
            Navigator.of(context).pop();
          }
        },
        label: const Text("Save"),
        icon: const Icon(Icons.save),
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

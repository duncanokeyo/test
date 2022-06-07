import 'dart:async';

import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/SessionNote.dart';
import 'package:bridgemetherapist/pages/sessionNotes/AddSessionNotes.dart';
import 'package:bridgemetherapist/pages/sessionNotes/EditSessionNotes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';


class SessionNotesList extends StatefulWidget {
  String patientId;
  String therapistId;
  //SessionBookings? sessionBookings;

  SessionNotesList({
    required this.patientId,
    required this.therapistId,
    //required this.sessionBookings
  });
  @override
  State<StatefulWidget> createState() {
    return SessionNotesListListState();
  }
}

class SessionNotesListListState extends State<SessionNotesList> {
  var _fetching = false;
  var _errorFetching = false;
  StreamSubscription? subscription;
  List<SessionNote>? _sessionNotes = <SessionNote>[];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  _refresh() {
    subscription?.cancel();
    _fetch();
  }

  _fetch() async {
    setState(() {
      _fetching = true;
      _errorFetching = false;
    });

    var response = await supabase
        .from('session_notes')
        .select('*')
        .eq('therapist_id', widget.therapistId)
        .eq('patient_id', widget.patientId)
        .execute();

    if (response.hasError) {
      setState(() {
        _fetching = false;
        _errorFetching = true;
      });
      return;
    }

    List<SessionNote> list = sessionNotesFromMap(response.data);

    setState(() {
      _fetching = false;
      _errorFetching = false;
      _sessionNotes = list;
    });
  }

  Future<void> _deleteSessionNote(SessionNote item) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'Deleting session note');

//    post!.posts = element;

    var response = await supabase
        .from('session_notes')
        .delete()
        .eq('therapist_id', supabase.auth.currentUser!.id)
        .eq('patient_id', widget.patientId)
        .eq('date_booked', Utils.getParamTimeFormat(item.dateBooked))
        .eq('time_booked', Utils.getTimeOfDayParam(item.timeBooked))
        .execute();

    pd.close();
    if (response.hasError) {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentState!.context)
          .showSnackBar(
              const SnackBar(content: Text("Error deleting session note")));
      return;
    }

    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Notes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kColorDarkGreen,
        onPressed: () {
          // if (widget.sessionBookings == null) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text("No active session"),
          //     ),
          //   );
          // } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSessionNotes(
                patientId: widget.patientId,
                //     dateBooked: widget.sessionBookings!.dateBooked,
                //     timeBooked: widget.sessionBookings!.time,
              ),
            ),
          ).then((value) {
            _fetch();
          });
          //}
        },
        icon: const Icon(Icons.add),
        label: const Text("Add session note"),
      ),
      body: _fetching
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _errorFetching
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: InkWell(
                    onTap: () {
                      _fetch();
                    },
                    child: Center(
                      child: const Text(
                          "Error fetching session notes, Tap to refresh"),
                    ),
                  ),
                )
              : (_sessionNotes == null || _sessionNotes!.isEmpty)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: InkWell(
                        onTap: () {
                          _fetch();
                        },
                        child: const Center(
                          child: Text(
                              "You havent entered session notes for this patient"),
                        ),
                      ),
                    )
                  : Padding(
                    padding: kIsWeb?EdgeInsets.only(left: WEBPADDING,right: WEBPADDING):const EdgeInsets.all(8.0),
                    child: SmartRefresher(
                        controller: _refreshController,
                        enablePullDown: true,
                        enablePullUp: false,
                        onRefresh: () {
                          _refresh();
                          _refreshController.refreshCompleted();
                        },
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              SessionNote item = _sessionNotes![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 10.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditSessionNotes(
                                            patientId: widget.patientId,
                                            time: item.timeBooked,
                                            date: item.dateBooked),
                                      ),
                                    ).then((value) {
                                      _refresh();
                                    });
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      title: Text("Session @ " +
                                          Utils.humanReadableDate(
                                              item.dateBooked) +
                                          " " +
                                          Utils.humanReadableTimeOfDay(
                                              item.timeBooked)),
                                      subtitle: Text(item.content),
                                      trailing: InkWell(
                                        onTap: () {
                                          _deleteSessionNote(item);
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: kColorDarkGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider(
                                color: Colors.grey,
                              );
                            },
                            itemCount: _sessionNotes!.length),
                      ),
                  ),
    );
  }
}

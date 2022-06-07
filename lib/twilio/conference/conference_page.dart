import 'dart:async';

import 'package:bridgemetherapist/countdown/count_down_flutter.dart';
import 'package:bridgemetherapist/extensions.dart';
import 'package:bridgemetherapist/model/AccurateDateTime.dart';
import 'package:bridgemetherapist/model/StatusLogTherapist.dart';
import 'package:bridgemetherapist/twilio/conference/conference_button_bar.dart';
import 'package:bridgemetherapist/twilio/conference/conference_room.dart';
import 'package:bridgemetherapist/twilio/conference/draggable_publisher.dart';
import 'package:bridgemetherapist/twilio/conference/participant_widget.dart';
import 'package:bridgemetherapist/twilio/debug.dart';
import 'package:bridgemetherapist/twilio/room/room_model.dart';
import 'package:bridgemetherapist/twilio/shared/widgets/noise_box.dart';
import 'package:bridgemetherapist/twilio/shared/widgets/platform_alert_dialog.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConferencePage extends StatefulWidget {
  final RoomModel roomModel;
  int timeRemainingInSeconds;
  final AccurateDateTime accurateDateTime;
  final TimeOfDay endTime;
  final TimeOfDay startTime;
  final int slotSize;
  final int sessionBookingId;
  final DateTime dateBooked;

  ConferencePage(
      {Key? key,
      required this.timeRemainingInSeconds,
      required this.accurateDateTime,
      required this.endTime,
      required this.dateBooked,
      required this.sessionBookingId,
      required this.startTime,
      required this.roomModel,
      required this.slotSize})
      : super(key: key);

  @override
  _ConferencePageState createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage>
    with SingleTickerProviderStateMixin {
  final StreamController<bool> _onButtonBarVisibleStreamController =
      StreamController<bool>.broadcast();
  final StreamController<double> _onButtonBarHeightStreamController =
      StreamController<double>.broadcast();
  ConferenceRoom? _conferenceRoom;
  late StreamSubscription _onConferenceRoomException;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _lockInPortrait();
    }
    _connectToRoom();
    if (!kIsWeb) {
      _wakeLock(true);
    }
  }

  _onEnd() {
    //_onHangup();
  }

  void _connectToRoom() async {
    try {
      final conferenceRoom = ConferenceRoom(
        name: widget.roomModel.name!,
        token: widget.roomModel.token!,
        identity: widget.roomModel.identity!,
      );
      await conferenceRoom.connect();
      setState(() {
        _conferenceRoom = conferenceRoom;
        _onConferenceRoomException =
            conferenceRoom.onException.listen((err) async {
          await _showPlatformAlertDialog(err);
        });
        conferenceRoom.addListener(_conferenceRoomUpdated);
      });
    } catch (err) {
      Debug.log(err);
      await _showPlatformAlertDialog(err);
      Navigator.of(context).pop();
    }
  }

  Future _showPlatformAlertDialog(err) async {
    if (kIsWeb) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            err is PlatformException
                ? err.message ?? 'An error occurred'
                : 'An error occurred',
          ),
          content: Text(err is PlatformException
              ? (err.details ?? err.toString())
              : err.toString()),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // dismisses only the dialog and returns nothing
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      await PlatformAlertDialog(
        title: err is PlatformException
            ? err.message ?? 'An error occurred'
            : 'An error occurred',
        content: err is PlatformException
            ? (err.details ?? err.toString())
            : err.toString(),
        defaultActionText: 'OK',
      ).show(context);
    }
  }

  Future<void> _lockInPortrait() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _freePortraitLock();
    _wakeLock(false);
    _disposeStreamsAndSubscriptions();
    _conferenceRoom?.removeListener(_conferenceRoomUpdated);
    super.dispose();
  }

  Future<void> _freePortraitLock() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _disposeStreamsAndSubscriptions() async {
    await _onButtonBarVisibleStreamController.close();
    await _onButtonBarHeightStreamController.close();
    await _onConferenceRoomException.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: buildLayout(),
      ),
    );
  }

  Widget buildLayout() {
    final conferenceRoom = _conferenceRoom;

    return conferenceRoom == null
        ? showProgress()
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: <Widget>[
                  _buildParticipants(
                      context, constraints.biggest, conferenceRoom),
                  Padding(
                    padding: const EdgeInsets.only(top: 60, left: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Countdown(
                          duration:
                              Duration(seconds: widget.timeRemainingInSeconds),
                          onFinish: () {
                            _onHangup();
                          },
                          builder: (BuildContext ctx, Duration remaining) {
                            if (remaining.inMinutes <= 1) {
                              return Text(
                                '${remaining.inHours} hrs: ${remaining.inMinutes % 60} mins: ${remaining.inSeconds % 60} secs remaining',
                                style: const TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gotik'),
                              );
                            } else {
                              return Text(
                                '${remaining.inHours} hrs: ${remaining.inMinutes % 60} mins: ${remaining.inSeconds % 60} secs remaining',
                                style: const TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gotik'),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  ConferenceButtonBar(
                    audioEnabled: conferenceRoom.onAudioEnabled,
                    videoEnabled: conferenceRoom.onVideoEnabled,
                    flashState: conferenceRoom.flashStateStream,
                    speakerState: conferenceRoom.speakerStateStream,
                    onAudioEnabled: conferenceRoom.toggleAudioEnabled,
                    onVideoEnabled: conferenceRoom.toggleVideoEnabled,
                    onHangup: _onHangup,
                    onSwitchCamera: conferenceRoom.switchCamera,
                    onToggleSpeaker: conferenceRoom.toggleSpeaker,
                    toggleFlashlight: conferenceRoom.toggleFlashlight,
                    onPersonAdd: _onPersonAdd,
                    onPersonRemove: _onPersonRemove,
                    onHeight: _onHeightBar,
                    onShow: _onShowBar,
                    onHide: _onHideBar,
                  ),
                ],
              );
            },
          );
  }

  Widget showProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const <Widget>[
        Center(child: CircularProgressIndicator()),
        SizedBox(
          height: 10,
        ),
        Text(
          'Connecting to the room...',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Future<void> _onHangup() async {
    Debug.log('onHangup');
    bool hangUp = await initiateHangUp();
    if (!hangUp) {
      Widget okButton = TextButton(
        child: const Text("retry"),
        onPressed: () {
          Navigator.of(context).pop();

          _onHangup();
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: const Text("Error occured"),
        content: const Text("Error disconnecting room, retry"),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    await _conferenceRoom?.disconnect();
    Navigator.of(context).pop();
  }

  Future<bool> initiateHangUp() async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'Disconnecting from room');

    var accurateDateTimeFetch =
        await supabase.rpc('accurate_date_time').execute();

    if (accurateDateTimeFetch.hasError) {
      pd.close();
      return false;
    }
    var accurateDateTime =
        accurateDateTimeFromMap(accurateDateTimeFetch.data)[0];

    TimeOfDay accurateTimeOfDay = accurateDateTime!.time;
    TimeOfDay sessionEndTime = widget.startTime.plusMinutes(widget.slotSize);

    if (accurateTimeOfDay.compareTo(sessionEndTime) == 0 ||
        accurateTimeOfDay.compareTo(sessionEndTime) == 1) {
      var updateEndTime = await supabase
          .from('session_bookings')
          .update({'completed': true})
          .eq('id', widget.sessionBookingId)
          .execute();

      if (updateEndTime.hasError) {
        pd.close();
        return false;
      }
    }

    StatusLogTherapist? statusLog;

    var statusLogsFetch = await supabase
        .from('session_bookings')
        .select('therapist_status_logs')
        .eq('id', widget.sessionBookingId)
        .execute();

    if (statusLogsFetch.hasError) {
      pd.close();
      return false;
    }

    List<StatusLogTherapist> statusLogs =
        statusLogFromMap(statusLogsFetch.data);

    if (statusLogs.isNotEmpty) {
      statusLog = statusLogs[0];
    }

    if (statusLog == null) {
      statusLog = StatusLogTherapist(statusLogs: [
        StatusLogElement(
            type: Status.THERAPIST_ENDED_CALL,
            date: accurateDateTime!.getDateWithTime())
      ]);
    } else {
      statusLog.statusLogs.add(StatusLogElement(
          type: Status.THERAPIST_ENDED_CALL,
          date: accurateDateTime!.getDateWithTime()));
    }

    print('status log to map----->${statusLog.toMap()}');

    var updateStatusResponse = await supabase
        .from('session_bookings')
        .update(statusLog.toMap())
        .eq('id', widget.sessionBookingId)
        .execute();

    if (updateStatusResponse.hasError) {
      pd.close();
      return false;
    }

    pd.close();
    return true;
  }

  void _onPersonAdd() {
    final conferenceRoom = _conferenceRoom;
    if (conferenceRoom == null) return;

    Debug.log('onPersonAdd');
    try {
      conferenceRoom.addDummy(
        child: Stack(
          children: <Widget>[
            const Placeholder(),
            Center(
              child: Text(
                (conferenceRoom.participants.length + 1).toString(),
                style: const TextStyle(
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Shadow(
                      blurRadius: 8.0,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ],
                  fontSize: 80,
                ),
              ),
            ),
          ],
        ),
      );
    } on PlatformException catch (err) {
      _showPlatformAlertDialog(err);
    }
  }

  void _onPersonRemove() {
    Debug.log('onPersonRemove');
    _conferenceRoom?.removeDummy();
  }

  Widget _buildParticipants(
      BuildContext context, Size size, ConferenceRoom conferenceRoom) {
    final children = <Widget>[];
    final length = conferenceRoom.participants.length;

    if (length <= 2) {
      _buildOverlayLayout(context, size, children);
      return Stack(children: children);
    }

    void buildInCols(bool removeLocalBeforeChunking,
        bool moveLastOfEachRowToNextRow, int columns) {
      _buildLayoutInGrid(
        context,
        size,
        children,
        removeLocalBeforeChunking: removeLocalBeforeChunking,
        moveLastOfEachRowToNextRow: moveLastOfEachRowToNextRow,
        columns: columns,
      );
    }

    if (length <= 3) {
      buildInCols(true, false, 1);
    } else if (length == 5) {
      buildInCols(false, true, 2);
    } else if (length <= 6 || length == 8) {
      buildInCols(false, false, 2);
    } else if (length == 7 || length == 9) {
      buildInCols(true, false, 2);
    } else if (length == 10) {
      buildInCols(false, true, 3);
    } else if (length == 13 || length == 16) {
      buildInCols(true, false, 3);
    } else if (length <= 18) {
      buildInCols(false, false, 3);
    }

    return Column(
      children: children,
    );
  }

  void _buildOverlayLayout(
      BuildContext context, Size size, List<Widget> children) {
    final conferenceRoom = _conferenceRoom;
    if (conferenceRoom == null) return;

    final participants = conferenceRoom.participants;
    if (participants.length == 1) {
      children.add(_buildNoiseBox());
    } else {
      final remoteParticipant = participants.firstWhereOrNull(
          (ParticipantWidget participant) => participant.isRemote);
      if (remoteParticipant != null) {
        children.add(remoteParticipant);
      }
    }

    final localParticipant = participants.firstWhereOrNull(
        (ParticipantWidget participant) => !participant.isRemote);
    if (localParticipant != null) {
      children.add(DraggablePublisher(
        key: Key('publisher'),
        availableScreenSize: size,
        onButtonBarVisible: _onButtonBarVisibleStreamController.stream,
        onButtonBarHeight: _onButtonBarHeightStreamController.stream,
        child: localParticipant,
      ));
    }
  }

  void _buildLayoutInGrid(
    BuildContext context,
    Size size,
    List<Widget> children, {
    bool removeLocalBeforeChunking = false,
    bool moveLastOfEachRowToNextRow = false,
    int columns = 2,
  }) {
    final conferenceRoom = _conferenceRoom;
    if (conferenceRoom == null) return;

    final participants = conferenceRoom.participants;
    ParticipantWidget? localParticipant;
    if (removeLocalBeforeChunking) {
      localParticipant = participants.firstWhereOrNull(
          (ParticipantWidget participant) => !participant.isRemote);
      if (localParticipant != null) {
        participants.remove(localParticipant);
      }
    }
    final chunkedParticipants = chunk(array: participants, size: columns);
    if (localParticipant != null) {
      chunkedParticipants.last.add(localParticipant);
      participants.add(localParticipant);
    }

    if (moveLastOfEachRowToNextRow) {
      for (var i = 0; i < chunkedParticipants.length - 1; i++) {
        var participant = chunkedParticipants[i].removeLast();
        chunkedParticipants[i + 1].insert(0, participant);
      }
    }

    for (final participantChunk in chunkedParticipants) {
      final rowChildren = <Widget>[];
      for (final participant in participantChunk) {
        rowChildren.add(
          Container(
            width: size.width / participantChunk.length,
            height: size.height / chunkedParticipants.length,
            child: participant,
          ),
        );
      }
      children.add(
        Container(
          height: size.height / chunkedParticipants.length,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowChildren,
          ),
        ),
      );
    }
  }

  NoiseBox _buildNoiseBox() {
    return NoiseBox(
      density: NoiseBoxDensity.xLow,
      backgroundColor: Colors.grey.shade900,
      child: Center(
        child: Container(
          color: Colors.black54,
          width: double.infinity,
          height: 40,
          child: Center(
            child: Text(
              'Waiting for another participant to connect to the room...',
              key: Key('text-wait'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  List<List<T>> chunk<T>({required List<T> array, required int size}) {
    final result = <List<T>>[];
    if (array.isEmpty || size <= 0) {
      return result;
    }
    var first = 0;
    var last = size;
    final totalLoop = array.length % size == 0
        ? array.length ~/ size
        : array.length ~/ size + 1;
    for (var i = 0; i < totalLoop; i++) {
      if (last > array.length) {
        result.add(array.sublist(first, array.length));
      } else {
        result.add(array.sublist(first, last));
      }
      first = last;
      last = last + size;
    }
    return result;
  }

  void _onHeightBar(double height) {
    _onButtonBarHeightStreamController.add(height);
  }

  void _onShowBar() {
    setState(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    });
    _onButtonBarVisibleStreamController.add(true);
  }

  void _onHideBar() {
    setState(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    });
    _onButtonBarVisibleStreamController.add(false);
  }

  Future<void> _wakeLock(bool enable) async {
    try {
      return await (enable ? Wakelock.enable() : Wakelock.disable());
    } catch (err) {
      Debug.log('Unable to change the Wakelock and set it to $enable');
      Debug.log(err);
    }
  }

  void _conferenceRoomUpdated() {
    setState(() {});
  }
}

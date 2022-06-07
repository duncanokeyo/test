import 'dart:collection';
import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/AccurateDateTime.dart';
import 'package:bridgemetherapist/model/Profile.dart';
import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:bridgemetherapist/pages/messages/TwilioVideoFetchTokenResponse.dart';
import 'package:bridgemetherapist/twilio/debug.dart';
import 'package:bridgemetherapist/twilio/room/room_model.dart';
import 'package:bridgemetherapist/twilio/shared/services/platform_service.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../extensions.dart';

import '../../twilio/conference/conference_page.dart';

class CustomVideoRoomInitPage extends StatefulWidget {
  int sessionId;
  String patientId;
  String therapistId;
  int slotSize;
  TimeOfDay time;
  DateTime dateBooked;

  SessionBookings sessionBooking;

  CustomVideoRoomInitPage(
      {Key? key,
      required this.sessionId,
      required this.patientId,
      required this.therapistId,
      required this.dateBooked,
      required this.slotSize,
      required this.time,
      required this.sessionBooking})
      : super(key: key);

  @override
  State<CustomVideoRoomInitPage> createState() =>
      _CustomVideoRoomInitPageState();
}

class _CustomVideoRoomInitPageState extends State<CustomVideoRoomInitPage> {
  bool _presetsLoading = false;
  bool _errorOccured = false;
  String _errorMessage = "";
  AccurateDateTime? accurateDateTime;
  int _timeRemainingInSeconds = 0;
  var box = Get.find<GetStorage>();

  late String roomName =
      "${widget.sessionId}${widget.therapistId}${widget.patientId}";

  @override
  void initState() {
    super.initState();
    //check how much time is remaining...
    _initialize();
  }

  _initialize() async {
    //print("room name -----> " + roomName);

    setState(() {
      _presetsLoading = true;
      _errorOccured = false;
      _errorMessage = "";
    });

    var storeKey = Utils.humanReadableDate(widget.sessionBooking.dateBooked) +
        "_" +
        Utils.humanReadableTimeOfDay(widget.sessionBooking.time) +
        "_" +
        widget.sessionBooking.patientId;

    bool? previouslySent = box.read(storeKey);

    bool sendNotification = previouslySent == null || previouslySent == false;

    Map<String, dynamic> data = HashMap();
    Map<String, dynamic> notificaiton = HashMap();
    Profile profile = profileFromMap(Get.find<GetStorage>().read('profile'))[0];

    data["to"] = "/topics/${widget.patientId}";
    notificaiton["title"] = "Appointment";
    notificaiton["body"] =
        "You have an appointment now with therapist ${profile.username}";
    data["notification"] = notificaiton;

    data["data"] = widget.sessionBooking
        .toMap(profile.id, profile.avatarUrl, profile.username);

    var uniqueId = await _getDeviceId();
    var twilioVideoFetchToken =
        await supabase.rpc('twilio_video_fetch_token', params: {
      'send_notification': sendNotification,
      'is_therapist': true,
      '_identity': uniqueId,
      'unique_room_name': roomName,
      'client_message': jsonEncode(data),
      'session_booking_id': widget.sessionBooking.id,
    }).execute();

    print(twilioVideoFetchToken.toJson());

    if (twilioVideoFetchToken.hasError) {
      setState(() {
        _presetsLoading = false;
        _errorOccured = true;
      });
      return;
    }

    TwilioVideoFetchTokenResponse results =
        twilioVideoFetchTokenResponseFromJson(twilioVideoFetchToken.data);

    if (results.error) {
      setState(() {
        _presetsLoading = false;
        _errorOccured = true;
        _errorMessage = results.errorMessage;
      });
      return;
    }

    _timeRemainingInSeconds = results.timeRemainingInSeconds();

    RoomModel model =
        RoomModel(name: roomName, token: results.content, identity: uniqueId);
    box.write(storeKey, true);

    setState(() {
      _presetsLoading = false;
      _errorOccured = false;
    });

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<ConferencePage>(
        fullscreenDialog: true,
        builder: (BuildContext context) => ConferencePage(
          roomModel: model,
          slotSize: widget.sessionBooking.slotSize,
          sessionBookingId: widget.sessionBooking.id,
          accurateDateTime: results.accurateDateTimeFrom(),
          startTime: widget.time,
          endTime: widget.time.plusMinutes(widget.slotSize),
          dateBooked: widget.dateBooked,
          timeRemainingInSeconds: _timeRemainingInSeconds,
        ),
      ),
    );
  }

  Future<String> _getDeviceId() async {
    try {
      return await PlatformService.deviceId;
    } catch (err) {
      Debug.log(err);
      return widget.therapistId;
//      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _presetsLoading
            ? Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 3,
                      ),
                      Text("initializing ...")
                    ],
                  ),
                ),
              )
            : _errorOccured
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_errorMessage.isNotEmpty) ...[
                          Text(_errorMessage),
                        ] else ...[
                          const Text("Error initializing video chat"),
                        ],
                        const SizedBox(
                          height: 3,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _initialize();
                          },
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: kColorDarkGreen),
                          ),
                        ),
                        const SizedBox(height: 5),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Go back",
                            style: TextStyle(color: kColorDarkGreen),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }
}

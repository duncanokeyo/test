import 'dart:collection';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/components/custom_button.dart';
import 'package:bridgemetherapist/components/day_item.dart';
import 'package:bridgemetherapist/components/time_slot_item.dart';
import 'package:bridgemetherapist/controller/JournalController.dart';
import 'package:bridgemetherapist/model/SessionStartEndTime.dart';
import 'package:bridgemetherapist/model/Sessions.dart';
import 'package:bridgemetherapist/model/Slot.dart';
import 'package:bridgemetherapist/pages/journals/journal_list.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../extensions.dart';

class EditAvailability extends StatefulWidget {
  Sessions session;

  EditAvailability({required this.session});
  @override
  State<StatefulWidget> createState() {
    return _EditAvailabilityState();
  }
}

class _EditAvailabilityState extends State<EditAvailability> {
  var _fetching = false;
  var _errorFetching = false;

  var _processing = false;
  var _startDate = DateTime.now();
  var _endDate = DateTime.now();
  var _slots = <Slot>[];

  var _startTime = Utils.timeOfDayFromString("08:00");
  var _endTime = Utils.timeOfDayFromString("24:00");
  TextEditingController priceController = TextEditingController();
  TextEditingController restTimeBetweenSessionsController =
      TextEditingController();

  var _savedTimeNotAvailable = <TimeOfDay>[];
  var _sessionBookings = <EditSessionBooking>[];

  var _accurateDate;
  var _selectedSlotSize;
//  var _pricePerMinute;
  var _accurateTime;
  int restTime = 10;

  Map<TimeOfDay, bool> selectedTimeSlots = HashMap();
  Map<String, bool> selectedDaysAvailable = HashMap();

  @override
  void initState() {
    super.initState();

    selectedDaysAvailable["Monday"] = true;
    selectedDaysAvailable["Tuesday"] = true;
    selectedDaysAvailable["Wednesday"] = true;
    selectedDaysAvailable["Thursday"] = true;
    selectedDaysAvailable["Friday"] = true;
    selectedDaysAvailable["Saturday"] = true;
    selectedDaysAvailable["Sunday"] = true;

    _fetch();
  }

  _save(context) async {
    var _pricePerMinute = priceController.text;

    if (_pricePerMinute.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Price cannot be empty"),
        ),
      );
      return;
    }
    if (!Utils.isNumeric(_pricePerMinute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid price"),
        ),
      );
      return;
    }
    //if (_pricePerMinute == 0.0) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //  const SnackBar(
    //    content: Text("Price cannot be zero"),
    //  ),
    //  );
    //  return;
    // }
    if (_startTime.compareTo(_endTime) == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Start time cannot be greater than end time"),
        ),
      );
      return;
    }
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Start date cannot be after end date"),
        ),
      );
      return;
    }
    if (selectedDaysAvailable.isEmpty ||
        !selectedDaysAvailable.values.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Select the days you will be available")));
      return;
    }

    if (selectedTimeSlots.isEmpty || !selectedTimeSlots.values.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select time you will be available")));
      return;
    }

    setState(() {
      _processing = true;
    });

    var checkSessionOverlap = await supabase
        .from('sessions')
        .select('start_date,end_date')
        .eq('therapist_id', supabase.auth.currentUser!.id)
        .neq('id', widget.session.id)
        .execute();

    if (checkSessionOverlap.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error saving session, try again")));
      setState(() {
        _processing = false;
      });
      return;
    }

    String errorMessage = "";
    // print(checkSessionOverlap.toJson());
    DateTime formattedSartDate =
        DateTime(_startDate.year, _startDate.month, _startDate.day);
    DateTime formattedEndDate =
        DateTime(_endDate.year, _endDate.month, _endDate.day);
    if ((checkSessionOverlap.data as List<dynamic>).isNotEmpty) {
      List<SessionStartEndTime> items =
          sessionStartEndTimeFromMap(checkSessionOverlap.data);

      for (var element in items) {
        //check for sessions that are matchinh
        if (element.startDate.isAtSameMomentAs(formattedSartDate) &&
            element.endDate.isAtSameMomentAs(formattedEndDate)) {
          errorMessage =
              "You have another session with the same start and end date";
          break;
        } else if ((element.startDate.isAtSameMomentAs(formattedEndDate) ||
                element.startDate.isBefore(formattedEndDate)) &&
            (element.endDate.isAfter(formattedSartDate) ||
                element.endDate.isAtSameMomentAs(formattedSartDate))) {
          errorMessage =
              "You have session overlap with session (${element.startDate.toString().split(' ')[0]} - ${element.endDate.toString().split(' ')[0]})\n";

          errorMessage = errorMessage +
              "New session (${formattedSartDate.toString().split(' ')[0]} - ${formattedEndDate.toString().split(' ')[0]})";

          break;
        }
      }
    }
    if (errorMessage.isNotEmpty) {
      Widget okButton = TextButton(
        child: const Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: const Text("Session overlap"),
        content: Text(errorMessage),
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
    }
    if (errorMessage.isNotEmpty) {
      setState(() {
        _processing = false;
      });
      return;
    }

    List<int> daysAvailable = [
      selectedDaysAvailable["Monday"] == true ? 1 : 0,
      selectedDaysAvailable["Tuesday"] == true ? 1 : 0,
      selectedDaysAvailable["Wednesday"] == true ? 1 : 0,
      selectedDaysAvailable["Thursday"] == true ? 1 : 0,
      selectedDaysAvailable["Friday"] == true ? 1 : 0,
      selectedDaysAvailable["Saturday"] == true ? 1 : 0,
      selectedDaysAvailable["Sunday"] == true ? 1 : 0,
    ];

    List<String> timeNotAvailable = [];
    selectedTimeSlots.forEach(
      (key, value) {
        if (!value) {
          timeNotAvailable.add(
              "${key.hour.toString().padLeft(2, '0')}:${key.minute.toString().padLeft(2, '0')}");
        }
      },
    );

    setState(() {
      _processing = true;
    });

    var response = await supabase.rpc('update_session', params: {
      'session_id_param': widget.session.id,
      'start_date_param': Utils.getParamTimeFormat(_startDate),
      'end_date_param': Utils.getParamTimeFormat(_endDate),
      'days_available_param': daysAvailable,
      'rest_time_between_slots_param':
          int.parse(restTimeBetweenSessionsController.text),
      'price_param': _calculateTotalAmount(), //_pricePerMinute,
      'start_time_param':
          "${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}",
      'end_time_param':
          "${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}",
      'slot_size_param': (_selectedSlotSize as Slot).slot,
      'time_not_available_param': timeNotAvailable
    }).execute();

    print(response.toJson());
    if (response.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error saving session")));
      setState(() {
        _processing = false;
      });
      return;
    }
    setState(() {
      _processing = false;
    });

    Navigator.of(context).pop();
  }

  _fetch() async {
    setState(() {
      _fetching = true;
      _errorFetching = false;
    });

    var response = await supabase.rpc('get_availability_presets').execute();

    print(response.toJson());
    if (response.hasError) {
      setState(() {
        _fetching = false;
        _errorFetching = true;
      });
      return;
    }

    var savedSessionTimes = await supabase
        .from('session_times')
        .select('*')
        .eq('session_id', widget.session.id)
        .execute();

    print(savedSessionTimes.toJson());
    if (savedSessionTimes.hasError) {
      setState(() {
        _fetching = false;
        _errorFetching = true;
      });
      return;
    }

    print(savedSessionTimes.toJson());
    if (savedSessionTimes.hasError) {
      setState(() {
        _fetching = false;
        _errorFetching = true;
      });
      return;
    }

    var sessionBookings = await supabase
        .from('session_bookings')
        .select('*')
        .eq('session_id', widget.session.id)
        .execute();

    print(sessionBookings.toJson());
    if (sessionBookings.hasError) {
      setState(() {
        _fetching = false;
        _errorFetching = true;
      });
      return;
    }
    //var bookedSessions = await supabase.from('session_bookings')

    SessionTimes sessionTimes = sessionsTimesFromMap(savedSessionTimes.data)[0];
    List<EditSessionBooking> editSessionBookings =
        editSessionFromMap(sessionBookings.data);

    List<int> savedDaysAvailable = widget.session.daysAvailable;

    // Slot? selectedSlot = null;
    // _slots.forEach((element) {
    //   if (element.slot == sessionTimes.slotSize) {
    //     selectedSlot = element;
    //   }
    // });
    print(savedDaysAvailable);
    setState(() {
      _fetching = false;
      _errorFetching = false;
      _slots = slotFromMap(response.data);
      _sessionBookings = editSessionBookings;
      _accurateDate = _slots[0].accurateDate;
      _accurateTime = _slots[0].accurateTime;
      restTime = sessionTimes.restTimeBetweenSlots;
      _savedTimeNotAvailable = sessionTimes.timeNotAvailable;
      _startTime = sessionTimes.startTime;
      _endTime = sessionTimes.endTime;
      _startDate = widget.session.startDate;
      _endDate = widget.session.endDate;
      // _pricePerMinute = sessionTimes.price;

      priceController.text = (sessionTimes.price / sessionTimes.slotSize)
          .toString(); //.toString();
      restTimeBetweenSessionsController.text =
          sessionTimes.restTimeBetweenSlots.toString();
      _selectedSlotSize = Slot(
          id: 0,
          slot: sessionTimes.slotSize,
          accurateDate: _accurateDate,
          accurateTime: _accurateTime); //sessionTimes.slotSize;

      selectedDaysAvailable["Monday"] = savedDaysAvailable[0] == 1;
      selectedDaysAvailable["Tuesday"] = savedDaysAvailable[1] == 1;
      selectedDaysAvailable["Wednesday"] = savedDaysAvailable[2] == 1;
      selectedDaysAvailable["Thursday"] = savedDaysAvailable[3] == 1;
      selectedDaysAvailable["Friday"] = savedDaysAvailable[4] == 1;
      selectedDaysAvailable["Saturday"] = savedDaysAvailable[5] == 1;
      selectedDaysAvailable["Sunday"] = savedDaysAvailable[6] == 1;

      print(sessionTimes.price);
    });
  }

  static const _txtStyle = TextStyle(
      fontSize: 15.5,
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontFamily: 'Gotik');
  _deleteSession(context) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'Deleting session');

    var response = await supabase.rpc('delete_session',
        params: {'session_id_param': widget.session.id}).execute();
    print(response.toJson());
    pd.close();
    if (response.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error deleting session")));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit session'),
        actions: [
          if (_sessionBookings.isEmpty && !_fetching) ...[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  Widget okButton = TextButton(
                    child: const Text("Delete"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteSession(context);
                    },
                  );

                  AlertDialog alert = AlertDialog(
                    title: const Text("Delete session"),
                    content:
                        Text("Are you sure you want to delete this session ?"),
                    actions: [
                      okButton,
                    ],
                  );
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                },
                child: Icon(
                  Icons.delete,
                  color: kColorDarkGreen,
                ),
              ),
            ),
          ]
        ],
      ),
      body: _fetching
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _errorFetching
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: InkWell(
                    onTap: () {
                      _fetch();
                    },
                    child: Center(
                      child: const Text(
                          "Error fetching time slots, Tap to refresh"),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: kIsWeb
                        ? EdgeInsets.only(left: WEBPADDING, right: WEBPADDING)
                        : const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 20.0, bottom: 10.0, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(
                                "Date Range",
                                style: _txtStyle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "From",
                                style: TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gotik'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: kColorDarkGreen)),
                              child: InkWell(
                                onTap: () async {
                                  final DateTime? dateTime =
                                      await showDatePicker(
                                          context: context,
                                          firstDate: _accurateDate,
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 1000)),
                                          initialDate: _startDate);

                                  if (dateTime != null &&
                                      dateTime != _startDate) {
                                    setState(() {
                                      _startDate = dateTime;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(Utils.displaydate(_startDate))
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "To",
                                style: TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gotik'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: kColorDarkGreen)),
                              child: InkWell(
                                onTap: () async {
                                  final DateTime? dateTime =
                                      await showDatePicker(
                                          context: context,
                                          firstDate: _accurateDate,
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 1000)),
                                          initialDate: _endDate);

                                  if (dateTime != null &&
                                      dateTime != _endDate) {
                                    setState(() {
                                      _endDate = dateTime;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(Utils.displaydate(_endDate))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 20.0, bottom: 10.0, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(
                                "Time range",
                                style: _txtStyle,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "From",
                                style: TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gotik'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: kColorDarkGreen)),
                              child: InkWell(
                                onTap: () async {
                                  final TimeOfDay? timeOfDay =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: _startTime,
                                    initialEntryMode: TimePickerEntryMode.input,
                                  );

                                  if (timeOfDay != null &&
                                      timeOfDay != _startTime) {
                                    setState(() {
                                      _startTime = timeOfDay;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.timelapse),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(Utils.humanReadableTimeOfDay(
                                        _startTime))
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "to",
                                style: TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gotik'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: kColorDarkGreen)),
                              child: InkWell(
                                onTap: () async {
                                  final TimeOfDay? timeOfDay =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: _endTime,
                                    initialEntryMode: TimePickerEntryMode.input,
                                  );

                                  if (timeOfDay != null &&
                                      timeOfDay != _endTime) {
                                    setState(() {
                                      _endTime = timeOfDay;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.timelapse),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(Utils.humanReadableTimeOfDay(_endTime))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 20.0, bottom: 10.0, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(
                                "On which days will you not be available? (click to deactivate)",
                                style: _txtStyle,
                              ),
                            ],
                          ),
                        ),
                        _daysAvailability(context),
                        if (_sessionBookings.isEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 20.0, bottom: 5.0, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                Text(
                                  "Time slot size",
                                  style: _txtStyle,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: FormField<Slot>(
                              builder: (FormFieldState<Slot> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                      labelStyle: _txtStyle,
                                      errorStyle: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16.0),
                                      hintText: 'Please select slot',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                  isEmpty: _selectedSlotSize == null,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Slot>(
                                      value: _selectedSlotSize,
                                      isDense: true,
                                      onChanged: (Slot? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedTimeSlots.clear();
                                            _selectedSlotSize = newValue;
                                            state.didChange(newValue);
                                          });
                                        }
                                      },
                                      items: _slots.map((Slot value) {
                                        return DropdownMenuItem<Slot>(
                                          value: value,
                                          child: Text(
                                              value.slot.toString() + " mins"),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 20.0, bottom: 5.0, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(
                                "Rest time between session (minutes)",
                                style: _txtStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: TextField(
                            controller: restTimeBetweenSessionsController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              hintText: 'time in minutes',
                            ),
                            onChanged: (r) {
                              selectedTimeSlots.clear();

                              if (Utils.isValidInt(r)) {
                                restTime = int.parse(r);
                                if (restTime < 0) {
                                  restTime = 0;
                                  restTimeBetweenSessionsController.text = "0";
                                }
                                setState(() {});
                              } else {
                                restTime = 0;
                                if (r.isNotEmpty) {
                                  restTimeBetweenSessionsController.text = "0";
                                }
                                setState(() {});
                              }
                            },
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: false, signed: false),
                            inputFormatters: const [
                              //  FilteringTextInputFormatter.
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 20.0, bottom: 5.0, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(
                                "Price per minute (ksh)",
                                style: _txtStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: TextField(
                            controller: priceController,
                            onChanged: (r) {
                              if (Utils.isNumeric(r)) {
                                var y = double.parse(r);
                                if (y < 0) {
                                  priceController.text = "0";
                                }
                                setState(() {
                                  //  restTime = int.parse(r);
                                });
                              } else {
                                if (r.isNotEmpty) {
                                  priceController.text = "0";
                                }
                                setState(() {});
                              }
                            },
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              hintText: 'amount',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              //  FilteringTextInputFormatter.
                            ],
                          ),
                        ),
                        _showAmount(context),
                        if (_startTime != null &&
                            _endTime != null &&
                            _selectedSlotSize != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 20.0, bottom: 5.0, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                Text(
                                  "Click on the time you will be not available",
                                  style: _txtStyle,
                                ),
                              ],
                            ),
                          ),
                          _displaySlots(context)
                        ],
                        if (_startTime != null &&
                            _endTime != null &&
                            _selectedSlotSize != null) ...[
                          if (!_processing) ...[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomButton(
                                text: "Save",
                                onPressed: () {
                                  _save(context);
                                },
                              ),
                            )
                          ] else ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          ]
                        ]
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _showAmount(context) {
    const _txtStyle = TextStyle(
        fontSize: 15.5,
        color: kColorDarkGreen,
        fontWeight: FontWeight.w700,
        fontFamily: 'Gotik');

    var _pricePerMinute = priceController.text;

    if (_selectedSlotSize == null) {
      return const Text("");
    }
    if (_pricePerMinute.isEmpty) {
      return const Text("");
    }

    if (!Utils.isNumeric(_pricePerMinute)) {
      return const Text("");
    }

    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 20.0, bottom: 5.0, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Total Amount: ${_calculateTotalAmount()} ksh for the ${(_selectedSlotSize as Slot).slot} min period",
            style: _txtStyle,
          ),
        ],
      ),
    );
  }

  double _calculateTotalAmount() {
    var _pricePerMinute = priceController.text;

    double price = double.parse(_pricePerMinute);
    int slot = (_selectedSlotSize as Slot).slot;
    double totalAmount = slot * price;
    return totalAmount;
  }

  Widget _daysAvailability(context) {
    List<String> days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.symmetric(horizontal: 10),
      crossAxisCount: 4,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: days.length,
      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemBuilder: (context, index) {
        String x = days[index];
        return DayItem(
          selected: selectedDaysAvailable.containsKey(x) &&
              selectedDaysAvailable[x] == true,
          day: days[index],
          onTap: () {
            print("ontap");
            bool hasKey = selectedDaysAvailable.containsKey(x);

            print('-----contains key $hasKey');
            if (hasKey) {
              selectedDaysAvailable[x] = !selectedDaysAvailable![x]!;
            } else {
              selectedDaysAvailable[x] = true;
            }
            print(selectedDaysAvailable);

            setState(() {});
            //Navigator.of(context).pushNamed(Routes.bookingStep4);
          },
        );
      },
    );
  }

  Widget _displaySlots(context) {
    List<TimeOfDay> slots = Utils.getTimes(_startTime, _endTime,
            Duration(minutes: (_selectedSlotSize as Slot).slot + restTime))
        .toList();

    if (selectedTimeSlots.length != slots.length) {
      selectedTimeSlots.clear();

      slots.forEach((element) {
        if (_savedTimeNotAvailable.contains(element)) {
          selectedTimeSlots[element] = false;
        } else {
          selectedTimeSlots[element] = true;
        }
      });
    }
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.symmetric(horizontal: 10),
      crossAxisCount: 4,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: slots.length,
      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemBuilder: (context, index) {
        TimeOfDay x = slots[index];
        return TimeSlotItem(
          selected:
              selectedTimeSlots.containsKey(x) && selectedTimeSlots[x] == true,
          slot: slots[index],
          onTap: () {
            print("ontap");
            bool hasKey = selectedTimeSlots.containsKey(x);

            print('-----contains key $hasKey');
            if (hasKey) {
              selectedTimeSlots[x] = !selectedTimeSlots![x]!;
            } else {
              selectedTimeSlots[x] = true;
            }
            print(selectedTimeSlots);

            setState(() {});
            //Navigator.of(context).pushNamed(Routes.bookingStep4);
          },
        );
      },
    );
  }
}

List<EditSessionBooking> editSessionFromMap(List<dynamic> items) =>
    List<EditSessionBooking>.from(
        items.map((x) => EditSessionBooking.fromMap(x)));

class EditSessionBooking {
  EditSessionBooking(
      {required this.id, required this.dateBooked, required this.timeBooked});

  int id;
  DateTime dateBooked;
  TimeOfDay timeBooked;

  factory EditSessionBooking.fromMap(Map<String, dynamic> json) =>
      EditSessionBooking(
        id: json["id"],
        dateBooked: DateTime.parse(json["date_booked"]),
        timeBooked: Utils.timeOfDayFromString(json["time"]),
      );
}

List<SessionTimes> sessionsTimesFromMap(List<dynamic> items) =>
    List<SessionTimes>.from(items.map((x) => SessionTimes.fromMap(x)));

class SessionTimes {
  SessionTimes(
      {required this.id,
      required this.price,
      required this.startTime,
      required this.endTime,
      required this.restTimeBetweenSlots,
      required this.slotSize,
      required this.timeNotAvailable});

  int id;
  double price;
  TimeOfDay startTime;
  TimeOfDay endTime;
  int slotSize;
  int restTimeBetweenSlots;
  List<TimeOfDay> timeNotAvailable;

  factory SessionTimes.fromMap(Map<String, dynamic> json) => SessionTimes(
        id: json["id"],
        price: double.parse(json["price"].toString()),
        startTime: Utils.timeOfDayFromString(json["start_time"]),
        restTimeBetweenSlots: json["rest_time_between_slots"],
        endTime: Utils.timeOfDayFromString(json["end_time"]),
        slotSize: json["slot_size"],
        timeNotAvailable: json["time_not_available"] == null
            ? []
            : List<TimeOfDay>.from(json["time_not_available"]
                .map((x) => Utils.timeOfDayFromString(x))),
      );
}

import 'package:bridgemetherapist/twilio/room/join_room_form.dart';
import 'package:flutter/material.dart';

class JoinRoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twilio Programmable Video'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: JoinRoomForm.create(context),
        ),
      ),
    );
  }
}

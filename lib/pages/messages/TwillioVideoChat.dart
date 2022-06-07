import 'package:bridgemetherapist/twilio/room/join_room_page.dart';
import 'package:bridgemetherapist/twilio/shared/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TwillioVideoChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<BackendService>(
      create: (_) => TwilioFunctionsService.instance,
      child: MaterialApp(
        title: 'Twilio Programmable Video',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.blue,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        home: JoinRoomPage(),
      ),
    );
  }
}

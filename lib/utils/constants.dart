import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const kColorGreen = Color.fromRGBO(
    0, 109, 15, 1); // Color.fromRGBO(97, 206, 112, 1); //Color(0xff2e83f8);
const kColorDarkGreen = Color.fromRGBO(0, 109, 15, 1); // Color(0xff1b3a5e);
const kColorPink = Color(0xffff748d);

final supabase = Supabase.instance.client;

const double WEBPADDING = 120;

final DEFUALT_USER_PROFILE =
    "https://xrcpwmndexxgbjtvorsz.supabase.co/storage/v1/object/public/defaults/icons8-person-90.png";

//rest time in minutes
final REST_TIME = 10;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}

//(97,206,112

const kInputTextStyle = TextStyle(
    fontSize: 14,
    color: Color(0xffbcbcbc),
    fontWeight: FontWeight.w300,
    fontFamily: 'NunitoSans');

const kColorPrimaryDark = Colors.black; //.fromRGBO(200, 125, 0, 1);

const kColorPrimary = Color.fromRGBO(204, 158, 26, 1);
const kColorSecondary = Color(0xffff748d);
const kColorDark = Color(0xff121212);
const kColorLight = Color(0xffEBF2F5);

const kBottomPadding = 48.0;
const double kDefaultPadding = 20.0;

const kSecondaryColor = Color(0xFF8B94BC);
const kGreenColor = Color(0xFF6AC259);
const kRedColor = Color(0xFFE92E30);
const kGrayColor = Color(0xFFC1C1C1);
const kBlackColor = Color(0xFF101010);
const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF46A0AE), Color(0xFF00FFCB)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const kTextStyleButton = TextStyle(
  color: kColorDarkGreen, //kColorPrimary,
  fontSize: 18,
  fontWeight: FontWeight.w500,
  fontFamily: 'NunitoSans',
);

const kTextStyleSubtitle1 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  fontFamily: 'NunitoSans',
);

const kTextStyleSubtitle2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  fontFamily: 'NunitoSans',
);

const kTextStyleBody2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  fontFamily: 'NunitoSans',
);

const kTextStyleHeadline6 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w500,
  fontFamily: 'NunitoSans',
);



// To parse this JSON data, do
//
//     final tourGuide = tourGuideFromMap(jsonString);

import 'dart:convert';

List<MpesaCredentials> mpesaCredentialsFromMap(List<dynamic> items) =>
    List<MpesaCredentials>.from(items.map((x) => MpesaCredentials.fromMap(x)));

class MpesaCredentials {
  MpesaCredentials(
      {required this.consumerKey,
      required this.consumerSecret,
      required this.passphrase,
      required this.callBack,
      required this.payBill});

  String consumerKey;
  String consumerSecret;
  String passphrase;
  String callBack;
  int payBill;

  factory MpesaCredentials.fromMap(Map<String, dynamic> json) =>
      MpesaCredentials(
        payBill: json['paybill'],
        consumerKey: json["consumer_key"] == null ? null : json["consumer_key"],
        consumerSecret:json["consumer_secret"] == null ? null : json["consumer_secret"],
        passphrase: json["passphrase"] == null ? "" : json["passphrase"],
        callBack: json["call_back"] == null ? "" : json["call_back"],
      );

  @override
  String toString() {
    // TODO: implement toString
    return "consumer key:$consumerKey\nconsumerSecret:$consumerSecret\npassphrase:$passphrase\ncallback:$callBack\nPaybill:$payBill";
  }
}

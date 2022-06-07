import 'dart:convert';
import 'dart:io';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/MpesaCredentials.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MpesaController {
  static String MPESA_CLIENT_CREDENTIALS_URL =
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
  static String MPESA_STK_PUSH_URL =
      "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";

  Future<ApiResponse> sendStkPush(
      double amount, String refNo, String phoneNumber) async {
    var box = Get.find<GetStorage>();
    MpesaCredentials credentials =
        mpesaCredentialsFromMap(box.read('mpesa_credentials'))[0];
    print(credentials);

    String value = "${credentials.consumerKey}:${credentials.consumerSecret}";
    print(value);
    var auth = 'Basic ' + base64Encode(value.codeUnits);
    print(auth);
    var apiResponse;
    try {
      final response = await http.get(Uri.parse(MPESA_CLIENT_CREDENTIALS_URL),
          headers: {"Authorization": auth, "Content-Type": "application/json"});

      print(response.reasonPhrase);
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var accessToken = json["access_token"];
        print(accessToken);

        apiResponse = await requestPayment(
            amount, refNo, phoneNumber, accessToken, credentials);
      } else {
        apiResponse = ApiResponse(
            responseCode: 0,
            response: "",
            error: "Error sending payment request",
            content: null);
      }
    } on SocketException catch (e) {
      print(e.message);
      apiResponse = ApiResponse(
          responseCode: 0,
          response: "",
          error: "Server error. Please retry",
          content: null);
    }

    return apiResponse;
  }

  Future<ApiResponse> requestPayment(
      double amount,
      String refNo,
      String phoneNumber,
      String accessToken,
      MpesaCredentials credentials) async {
    var timestamp = Utils.getMpesaTimestamp();
    print(credentials.payBill);
    var password = Utils.getMpesaPassWord(
        credentials.payBill, credentials.passphrase, timestamp);

    print("phone number is " + phoneNumber);
    var apiResponse;
    String callBackUrl = "${credentials.callBack}?refno=$refNo";
    print(callBackUrl);
    
    try {
      final response = await http.post(
        Uri.parse(MPESA_STK_PUSH_URL),
        headers: {
          'Authorization': 'Bearer ' + accessToken,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
          {
            "BusinessShortCode": credentials.payBill,
            "Password": password,
            "Timestamp": timestamp,
            "TransactionType": "CustomerPayBillOnline",
            "Amount": amount,
            "PartyA": phoneNumber.trim(),
            "PartyB": credentials.payBill,
            "PhoneNumber": phoneNumber.trim(),
            "CallBackURL": callBackUrl,
            "AccountReference": "Session payment",
            "Passkey": credentials.passphrase,
            "TransactionDesc": "Payment"
          },
        ),
      );

      print(response.body);
      if (response.statusCode == 200) {
        apiResponse = ApiResponse(
            responseCode: 0,
            response:
                "Payment request sent successfully, If you cannot received payment request on your simcard, kindly dial *234#Ok>M-pesa Products>Sim Card Upgrade/Update to allow you to receive the STK push when transacting. After STK push has been sent and you have paid, refresh this page for current balance to reflect",
            error: "",
            content: null);
      } else {
        apiResponse = ApiResponse(
            responseCode: 0,
            response: "",
            error: "Error sending payment request",
            content: null);
      }
    } on SocketException {
      apiResponse = ApiResponse(
          responseCode: 0,
          response: "",
          error: "Server error. Please retry",
          content: null);
    }

    return apiResponse;
  }
}

class ApiResponse {
  final int responseCode;
  final String response;
  final String error;
  final dynamic content;

  ApiResponse(
      {required this.responseCode,
      required this.response,
      required this.error,
      this.content});

  Map<String, dynamic> toMap() {
    return {
      'response_code': responseCode,
      'response': response,
      'error': error,
      'content': content,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}

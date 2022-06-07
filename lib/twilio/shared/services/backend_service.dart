//import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';
import 'dart:io';

import 'package:bridgemetherapist/twilio/models/twilio_list_room_request.dart';
import 'package:bridgemetherapist/twilio/models/twilio_list_room_response.dart';
import 'package:bridgemetherapist/twilio/models/twilio_room_by_sid_request.dart';
import 'package:bridgemetherapist/twilio/models/twilio_room_by_unique_name_request.dart';
import 'package:bridgemetherapist/twilio/models/twilio_room_request.dart';
import 'package:bridgemetherapist/twilio/models/twilio_room_response.dart';
import 'package:bridgemetherapist/twilio/models/twilio_room_token_request.dart';
import 'package:bridgemetherapist/twilio/models/twilio_room_token_response.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

abstract class BackendService {
  Future<TwilioRoomResponse> completeRoomBySid(
      TwilioRoomBySidRequest twilioRoomBySidRequest);
  Future<TwilioRoomResponse> createRoom(
      TwilioRoomRequest twilioRoomRequest, String? uniqueName);
  Future<TwilioRoomTokenResponse> createToken(
      TwilioRoomTokenRequest twilioRoomTokenRequest);
  Future<TwilioRoomResponse> getRoomBySid(
      TwilioRoomBySidRequest twilioRoomBySidRequest);
  Future<TwilioRoomResponse> getRoomByUniqueName(
      TwilioRoomByUniqueNameRequest twilioRoomByUniqueNameRequest);
  Future<TwilioListRoomResponse> listRooms(
      TwilioListRoomRequest twilioListRoomRequest);
  Future<bool> hasRoom(TwilioListRoomRequest twilioListRoomRequest);
}

class TwilioFunctionsService implements BackendService {
  TwilioFunctionsService._();

  static final instance = TwilioFunctionsService._();

  @override
  Future<TwilioRoomResponse> completeRoomBySid(
      TwilioRoomBySidRequest twilioRoomBySidRequest) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://twiliochatroomaccesstoken-7847.twil.io/completeroombysid"),
          body: twilioRoomBySidRequest.toMap());

      return TwilioRoomResponse.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body)));
    } catch (e) {
      print('-------------error thrown------------');
      print(e);

      throw PlatformException(
        code: "200",
        message: "Error occured",
        details: "Error occured",
      );
    }
  }

  @override
  Future<TwilioRoomResponse> createRoom(
      TwilioRoomRequest? twilioRoomRequest, String? uniqueName) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://twiliochatroomaccesstoken-7847.twil.io/createroom"),
          body: {"uniqueName": uniqueName});

      print('----------RESPONSE BODY------------->' + response.body.toString());
      print('----------REASON PHRASE------------->' + response.reasonPhrase!);

      if (response.statusCode != 200) {
        throw PlatformException(
            code: response.statusCode.toString(),
            message: response.body,
            details: response.body);
      }

      return TwilioRoomResponse.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body)));
    } on PlatformException catch (e) {
      print('-------------error thrown------------');
      print(e);

      throw PlatformException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    } on SocketException catch (e) {
      throw PlatformException(
          code: "400",
          message: "No internet connection",
          details: "No internet connection");
    }
  }

  @override
  // Future<TwilioListRoomResponse> listRooms(TwilioListRoomRequest twilioListRoomRequest) async {
  //   try {
  //     final response = await cf.httpsCallable('listRooms').call(twilioListRoomRequest.toMap());
  //    return TwilioListRoomResponse.fromMap(Map<String, dynamic>.from(response.data));
  //   } on FirebaseFunctionsException catch (e) {
  //     throw PlatformException(
  //       code: e.code,
  //       message: e.message,
  //       details: e.details,
  //     );
  //   }
  // }

  @override
  Future<TwilioRoomTokenResponse> createToken(
      TwilioRoomTokenRequest twilioRoomTokenRequest) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://twiliochatroomaccesstoken-7847.twil.io/accesstoken"),
          body: twilioRoomTokenRequest.toMap());

      if (response.statusCode != 200) {
        throw PlatformException(
            code: response.statusCode.toString(),
            message: response.body,
            details: response.body);
      }
      print('----------response body------------->' + response.body.toString());
      print('----------reason phrase------------->' + response.reasonPhrase!);

      return TwilioRoomTokenResponse.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body)));
    } on PlatformException catch (e) {
      print('-------------error thrown------------');
      print(e);
      throw PlatformException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    } on SocketException catch (e) {
      throw PlatformException(
        code: "400",
        message: "No internet connection",
        details: "No internet connection",
      );
    }
  }

  @override
  Future<TwilioRoomResponse> getRoomBySid(
      TwilioRoomBySidRequest twilioRoomBySidRequest) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://twiliochatroomaccesstoken-7847.twil.io/getroombysid"),
          body: twilioRoomBySidRequest.toMap());
      print('-------------error thrown------------');

      return TwilioRoomResponse.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body)));
    } catch (e) {
      print('-------------error thrown------------');
      print(e);

      throw PlatformException(
        code: "200",
        message: "Error occured",
        details: "Error occured",
      );
    }
  }

  @override
  Future<TwilioRoomResponse> getRoomByUniqueName(
      TwilioRoomByUniqueNameRequest twilioRoomByUniqueNameRequest) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://twiliochatroomaccesstoken-7847.twil.io/getroombyuniquename"),
          body: twilioRoomByUniqueNameRequest.toMap());
      print('-------------error thrown------------');

      return TwilioRoomResponse.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body)));
    } catch (e) {
      print('-------------error thrown------------');
      print(e);

      throw PlatformException(
        code: "200",
        message: "Error occured",
        details: "Error occured",
      );
    }
  }

  @override
  Future<TwilioListRoomResponse> listRooms(
      TwilioListRoomRequest twilioListRoomRequest) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://twiliochatroomaccesstoken-7847.twil.io/list_rooms"),
          body: twilioListRoomRequest.toMap());

      if (response.statusCode != 200) {
        throw PlatformException(
            code: response.statusCode.toString(),
            message: response.body,
            details: response.body);
      }
      return TwilioListRoomResponse.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body)));
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    }
  }

  @override
  Future<bool> hasRoom(TwilioListRoomRequest twilioListRoomRequest) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://twiliochatroomaccesstoken-7847.twil.io/list_rooms"),
          body: twilioListRoomRequest.toMap());

      if (response.statusCode != 200) {
        throw PlatformException(
            code: response.statusCode.toString(),
            message: response.body,
            details: response.body);
      }

      List<dynamic> roomResponse = jsonDecode(response.body);
      print(jsonDecode(response.body));

      if (roomResponse.isEmpty) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    }
  }
}



// class FirebaseFunctionsService implements BackendService {
//   @override
//   Future<TwilioRoomResponse> completeRoomBySid(
//       TwilioRoomBySidRequest twilioRoomBySidRequest) {
//     // TODO: implement completeRoomBySid
//     throw UnimplementedError();
//   }

//   @override
//   Future<TwilioRoomResponse> createRoom(TwilioRoomRequest twilioRoomRequest) {
//     // TODO: implement createRoom
//     throw UnimplementedError();
//   }

//   @override
//   Future<TwilioRoomTokenResponse> createToken(
//       TwilioRoomTokenRequest twilioRoomTokenRequest) {
//     // TODO: implement createToken
//     throw UnimplementedError();
//   }

//   @override
//   Future<TwilioRoomResponse> getRoomBySid(
//       TwilioRoomBySidRequest twilioRoomBySidRequest) {
//     // TODO: implement getRoomBySid
//     throw UnimplementedError();
//   }

//   @override
//   Future<TwilioRoomResponse> getRoomByUniqueName(
//       TwilioRoomByUniqueNameRequest twilioRoomByUniqueNameRequest) {
//     // TODO: implement getRoomByUniqueName
//     throw UnimplementedError();
//   }

//   @override
//   Future<TwilioListRoomResponse> listRooms(
//       TwilioListRoomRequest twilioListRoomRequest) {
//     // TODO: implement listRooms
//     throw UnimplementedError();
//   }
//   // FirebaseFunctionsService._();

//   // static final instance = FirebaseFunctionsService._();

//   // final FirebaseFunctions cf = FirebaseFunctions.instanceFor(region: 'europe-west1');

//   // @override
//   // Future<TwilioRoomResponse> completeRoomBySid(TwilioRoomBySidRequest twilioRoomBySidRequest) async {
//   //   try {
//   //     final response = await cf.httpsCallable('completeRoomBySid').call(twilioRoomBySidRequest.toMap());
//   //     return TwilioRoomResponse.fromMap(Map<String, dynamic>.from(response.data));
//   //   } on FirebaseFunctionsException catch (e) {
//   //     throw PlatformException(
//   //       code: e.code,
//   //       message: e.message,
//   //       details: e.details,
//   //     );
//   //   }
//   // }

//   // @override
//   // Future<TwilioRoomResponse> createRoom(TwilioRoomRequest twilioRoomRequest) async {
//   //   try {
//   //     final response = await cf.httpsCallable('createRoom').call(twilioRoomRequest.toMap());
//   //     return TwilioRoomResponse.fromMap(Map<String, dynamic>.from(response.data));
//   //   } on FirebaseFunctionsException catch (e) {
//   //     throw PlatformException(
//   //       code: e.code,
//   //       message: e.message,
//   //       details: e.details,
//   //     );
//   //   }
//   // }

//   // @override
//   // Future<TwilioRoomTokenResponse> createToken(TwilioRoomTokenRequest twilioRoomTokenRequest) async {
//   //   try {
//   //     final response = await cf.httpsCallable('createToken').call(twilioRoomTokenRequest.toMap());
//   //     return TwilioRoomTokenResponse.fromMap(Map<String, dynamic>.from(response.data));
//   //   } on FirebaseFunctionsException catch (e) {
//   //     throw PlatformException(
//   //       code: e.code,
//   //       message: e.message,
//   //       details: e.details,
//   //     );
//   //   }
//   // }

//   // @override
//   // Future<TwilioRoomResponse> getRoomBySid(TwilioRoomBySidRequest twilioRoomBySidRequest) async {
//   //   try {
//   //     final response = await cf.httpsCallable('getRoomBySid').call(twilioRoomBySidRequest.toMap());
//   //     return TwilioRoomResponse.fromMap(Map<String, dynamic>.from(response.data));
//   //   } on FirebaseFunctionsException catch (e) {
//   //     throw PlatformException(
//   //       code: e.code,
//   //       message: e.message,
//   //       details: e.details,
//   //     );
//   //   }
//   // }

//   // @override
//   // Future<TwilioRoomResponse> getRoomByUniqueName(TwilioRoomByUniqueNameRequest twilioRoomByUniqueNameRequest) async {
//   //   try {
//   //     final response = await cf.httpsCallable('getRoomByUniqueName').call(twilioRoomByUniqueNameRequest.toMap());
//   //     return TwilioRoomResponse.fromMap(Map<String, dynamic>.from(response.data));
//   //   } on FirebaseFunctionsException catch (e) {
//   //     throw PlatformException(
//   //       code: e.code,
//   //       message: e.message,
//   //       details: e.details,
//   //     );
//   //   }
//   // }

//   // @override
//   // Future<TwilioListRoomResponse> listRooms(TwilioListRoomRequest twilioListRoomRequest) async {
//   //   try {
//   //     final response = await cf.httpsCallable('listRooms').call(twilioListRoomRequest.toMap());
//   //     return TwilioListRoomResponse.fromMap(Map<String, dynamic>.from(response.data));
//   //   } on FirebaseFunctionsException catch (e) {
//   //     throw PlatformException(
//   //       code: e.code,
//   //       message: e.message,
//   //       details: e.details,
//   //     );
//   //   }
//   // }

// }

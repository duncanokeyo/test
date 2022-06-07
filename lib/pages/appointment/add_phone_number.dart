import 'package:bridgemetherapist/Utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import '../../components/custom_button.dart';
import '../../utils/constants.dart';

class AddPhoneNumberPage extends StatefulWidget {
  @override
  _AddPhoneNumberPageState createState() => _AddPhoneNumberPageState();
}

//payment methods are stored in cache
class _AddPhoneNumberPageState extends State<AddPhoneNumberPage> {
  var box = Get.find<GetStorage>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController phoneNumberController =  TextEditingController();
  addPhoneNumber(context) {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      List<MpesaPaymentMethod> mpesa = [];
      List<dynamic>? storedPaymentMethods = box.read('payment_methods');

      storedPaymentMethods?.forEach((element) {
        if (element['type'] == 1) {
          MpesaPaymentMethod method = MpesaPaymentMethod.fromMap(element);
          mpesa.add(method);
        }
      });

      bool contains = false;
      String phoneNumber = phoneNumberController.text;
      mpesa.forEach(
        (element) {
          if (phoneNumber == element.phoneNumber) {
            contains = true;
          }
        },
      );

      print(contains);
      if (contains) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Phone number already exists"),
          ),
        );
      } else {
        print("---is empty------");
        if (storedPaymentMethods == null || storedPaymentMethods.isEmpty) {
          var list = [];
          list.add(MpesaPaymentMethod(phoneNumber: phoneNumber).toMap());
          print(list);
          box.write('payment_methods', list);
        } else {
          storedPaymentMethods
              ?.add(MpesaPaymentMethod(phoneNumber: phoneNumber).toMap());
          box.write('payment_methods', storedPaymentMethods);
        }
        print(storedPaymentMethods);
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Phone Number'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Card(
          color:Colors.white,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: phoneNumberController,
                  validator: (String? val) {
                    if (val == null) {
                      return 'This field is required';
                    }
                    if (val.isEmpty) {
                      return 'This field is required';
                    }

                    if (val.contains('.') ||
                        val.contains('+') ||
                        val.contains('-')) {
                      return "Input has invalid characters";
                    }
                    if (!Utils.isNumeric(val)) {
                      return 'Invalid number';
                    }
                    if (val.length != 12) {
                      return "Invalid phone number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: kColorDarkGreen, width: 1.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: kColorDarkGreen, width: 1.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: kColorDarkGreen),
                    labelStyle: TextStyle(color: kColorDarkGreen),
                    labelText: "Phone number eg. 2547915077..",
                    hintText: "Phone number eg. 2547915077..",
                    fillColor: Colors.white70,
                    alignLabelWithHint: true,
                    isDense: true,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: CustomButton(
                    onPressed: () {
                      addPhoneNumber(context);
                    },
                    text: 'Add phone',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

abstract class PaymentMethod {
  int type = 0;
}

class MpesaPaymentMethod extends PaymentMethod {
  String phoneNumber;
  MpesaPaymentMethod({required this.phoneNumber});

  @override
  final type = 1;

  factory MpesaPaymentMethod.fromMap(Map<String, dynamic> json) =>
      MpesaPaymentMethod(phoneNumber: json["phone_number"]);

  Map<String, dynamic> toMap() {
    return {
      'phone_number': phoneNumber,
      'type': type,
    };
  }
}

class CardPaymentMethod extends PaymentMethod {
  String cardHoldersName;
  String cardNumber;
  String expiry;
  String cvv;
  String phoneNumber;
  String email;

  @override
  final type = 2;

  factory CardPaymentMethod.fromMap(Map<String, dynamic> json) =>
      CardPaymentMethod(
          cardHoldersName: json["card_holder_name"],
          cardNumber: json["card_number"],
          expiry: json["expiry"],
          cvv: json["cvv"],
          phoneNumber: json["phone_number"],
          email: json["email"]);

  CardPaymentMethod(
      {required this.cardHoldersName,
      required this.cardNumber,
      required this.expiry,
      required this.cvv,
      required this.phoneNumber,
      required this.email});

  Map<String, dynamic> toMap() {
    return {
      'card_holder_name': cardHoldersName,
      'card_number': cardNumber,
      'expiry': expiry,
      'type': type,
      'cvv': cvv,
      'phone_number': phoneNumber,
      'email': email
    };
  }
}

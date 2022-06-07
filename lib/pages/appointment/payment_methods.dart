import 'package:bridgemetherapist/model/Profile.dart';
import 'package:bridgemetherapist/pages/appointment/add_phone_number.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import '../../utils/constants.dart';

class PaymentMethodsPage extends StatefulWidget {
  Function function;

  PaymentMethodsPage({required this.function});

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

//payment methods are stored in cache
class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  var box = Get.find<GetStorage>();
  late Profile profile;
  var paymentMethods = [];
  @override
  void initState() {
    super.initState();
    fetchPaymentMethods();

    setState(() {});
  }

  removePaymentMethod(PaymentMethod item) {
    List<dynamic>? storedPaymentMethods = box.read('payment_methods');
    List<dynamic> newItems = [];

    storedPaymentMethods?.forEach((element) {
      if (item is MpesaPaymentMethod) {
        if (element['type'] == 1 &&
            element['phone_number'] != item.phoneNumber) {
          newItems.add(element);
        }
      } else if (item is CardPaymentMethod) {}
    });

    box.write('payment_methods', newItems);
    fetchPaymentMethods();
  }

  fetchPaymentMethods() {
    profile = profileFromMap(box.read('profile'))[0];
    List<dynamic>? storedPaymentMethods = box.read('payment_methods');

    print(storedPaymentMethods);

    if (storedPaymentMethods == null || storedPaymentMethods.isEmpty) {
      print(profile.phoneNumber);
      if (profile.phoneNumber.isNotEmpty &&
          profile.phoneNumber.startsWith("254") &&
          profile.phoneNumber.length == 12) {
        paymentMethods
            .add(MpesaPaymentMethod(phoneNumber: profile.phoneNumber));

        var list = [];
        list.add(MpesaPaymentMethod(phoneNumber: profile.phoneNumber).toMap());

        print(list);
        box.write('payment_methods', list);
      }
    } else {
      paymentMethods.clear();
      storedPaymentMethods.forEach((element) {
        if (element['type'] == 1) {
          paymentMethods.add(MpesaPaymentMethod.fromMap(element));
        } else {
          paymentMethods.add(CardPaymentMethod.fromMap(element));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_appointments'.tr()),
        elevation: 0,
      ),
      body: Column(
        children: [
          Divider(
            height: 0.5,
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                new MaterialPageRoute(builder: (_) => new AddPhoneNumberPage()),
              )
                  .then((val) {
                paymentMethods.clear();
                fetchPaymentMethods();
                setState(() {});
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.phone_android),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Add phone number"),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 0.5,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView(
              children: List.generate(
                paymentMethods.length,
                (index) {
                  var method = paymentMethods[index] as PaymentMethod;
                  if (method is MpesaPaymentMethod) {
                    return ListTile(
                      onTap: () {
                        widget.function(method);
                        Navigator.pop(context, true);
                      },
                      leading: Image.asset(
                        "assets/images/mpesa.png",
                        height: 40,
                        width: 40,
                      ),
                      title: Text(method.phoneNumber),
                      subtitle: Text("MPESA"),
                      trailing: IconButton(
                          onPressed: () {
                            removePaymentMethod(method);
                            setState(() {
                              
                            });
                          },
                          icon: Icon(Icons.close)),
                    );
                  } else {
                    return ListTile(
                      // leading: Image.asset("assets/images/mpesa.png"),
                      title: Text("**** **** ****"),
                      subtitle: Text("VISA"),
                    );
                  }
                },
              ),
            ),
          )
        ],
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

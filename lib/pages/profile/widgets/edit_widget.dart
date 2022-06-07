import 'dart:collection';
import 'dart:io';

import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/components/custom_button.dart';
import 'package:bridgemetherapist/model/Profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../components/text_form_field.dart';
import '../../../utils/constants.dart';

class EditWidget extends StatefulWidget {
  @override
  _EditWidgetState createState() => _EditWidgetState();
}

class _EditWidgetState extends State<EditWidget> {
  final ImagePicker _picker = ImagePicker();
  final box = Get.find<GetStorage>();
  final _formKey = GlobalKey<FormState>();

  late Profile profile;

  var _selectedGender = 'male';

  var _selectedBloodGroup = 'O+';
  final _selectedMarital = 'single';
  final _genderItems = <String>['male', 'female'];

  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  static const _bloodItems = <String>[
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  var _maritalItems = <String>['single'.tr(), 'married'.tr()];

  var _birthDate = '01/01/2000';

  late List<DropdownMenuItem<String>> _dropDownGender;
  late List<DropdownMenuItem<String>> _dropDownMarital;

  List<DropdownMenuItem<String>> _dropDownBlood = _bloodItems
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ))
      .toList();

  File? _image;

  Future _getImage(ImageSource imageSource) async {
    PickedFile? _imageFile;
    _imageFile = await _picker.getImage(source: imageSource);
    if (_imageFile != null) {
      setState(() {
        _image = File(_imageFile!.path);
      });
    }
    //uploadPic();
  }

  _initDropDowns() {
    print(_genderItems);
    _dropDownGender = _genderItems
        .map((String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ))
        .toList();

    _dropDownMarital = _maritalItems
        .map((String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _initDropDowns();

    profile = profileFromMap(box.read('profile'))[0];
    if (profile != null) {
      _selectedGender = profile.gender;
      print("selected gender is $_selectedGender");
      if (_selectedGender == null || _selectedGender.isEmpty) {
        _selectedGender = "male";
      } else {
        _selectedGender = _selectedGender.toLowerCase();
      }
      contactController.text = profile.phoneNumber;
      var nameSplit = profile.username.split(" ");
      firstNameController.text = nameSplit[0];
      if (nameSplit.length > 1) {
        secondNameController.text = nameSplit[1];
      }
    } else {
      _selectedGender = "male";
      contactController.text = "";
      firstNameController.text = "";
      secondNameController.text = "";
    }
  }

  var isProcessing = false;

  updateProfile(context) async {
    setState(() {
      isProcessing = true;
    });
    final form = _formKey.currentState;

    if (form != null && form.validate()) {
      form.save();

      String name =
          "${firstNameController.text.trim()} ${secondNameController.text.trim()}";
      var gender = "";
      if (_selectedGender.toLowerCase() == "male") {
        gender = "Male";
      } else {
        gender = "Female";
      }

      String contactNumber = contactController.text;
      FocusScope.of(context).unfocus();

      Map<dynamic, dynamic> update = HashMap();
      update["username"] = name;
      update["gender"] = gender;
      update["phone_number"] = contactNumber;

      final response = await supabase
          .from('profiles')
          .update(update)
          .eq('id', supabase.auth.currentUser!.id)
          .execute();

      setState(() {
        isProcessing = false;
      });

      if (response.error != null) {
        showMessage('Update failed: ${response.error!.message}');
      } else {
        profile.username = name;
        profile.phoneNumber = contactNumber;
        profile.gender = gender;

        box.write('profile', [profile.toMap()]);

        showMessage('Update success');
      }
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(NavigationService.navigatorKey.currentState!.context)
        .showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () {
                  _openBottomSheet(context);
                },
                child: _image == null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        //backgroundImage: NetworkImage(avatarUrl),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: FileImage(_image!),
                      ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  _openBottomSheet(context);
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(4)),
                child: Text(
                  'change_avatar'.tr(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              'first_name_dot'.tr(),
              style: kInputTextStyle,
            ),
            CustomTextFormField(
              hintText: 'John',
              controller: firstNameController,
              validator: (value) =>
                  value!.isEmpty ? 'Please insert a valid first name' : null,
            ),
            SizedBox(height: 15),
            Text(
              'last_name_dot'.tr(),
              style: kInputTextStyle,
            ),
            CustomTextFormField(
              hintText: 'Doe',
              controller: secondNameController,
              validator: (value) =>
                  value!.isEmpty ? 'Please insert a valid last name' : null,
            ),
            SizedBox(height: 15),
            Text(
              'contact_number_dot'.tr(),
              style: kInputTextStyle,
            ),
            CustomTextFormField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              hintText: '0781 34 86 77',
            ),
            SizedBox(height: 15),
            // Text(
            //   'email_dot'.tr(),
            //   style: kInputTextStyle,
            // ),
            // CustomTextFormField(
            //   hintText: 'bhr.tawfik@gmail.com',
            //   enabled: false,
            // ),
            SizedBox(height: 15),
            Text(
              'gender_dot'.tr(),
              style: kInputTextStyle,
            ),
            DropdownButton(
              isExpanded: true,
              value: _selectedGender,
              //hint: ,
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
              items: _dropDownGender,
            ),
            // SizedBox(height: 15),
            // Text(
            //   'date_of_birth_dot'.tr(),
            //   style: kInputTextStyle,
            // ),
            // ListTile(
            //   contentPadding: EdgeInsets.all(0),
            //   title: Text(_birthDate),
            //   onTap: () {
            //     showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(1900),
            //       lastDate: DateTime.now(),
            //     ).then((DateTime? value) {
            //       if (value != null) {
            //         setState(() {
            //           _birthDate = value.toString();
            //         });
            //       }
            //     });
            //   },
            // ),
            // SizedBox(height: 15),
            // Text(
            //   'blood_group_dot'.tr(),
            //   style: kInputTextStyle,
            // ),
            // DropdownButton(
            //   isExpanded: true,
            //   value: _selectedBloodGroup,
            //   //hint: ,
            //   onChanged: (String? value) {
            //     setState(() {
            //       _selectedBloodGroup = value!;
            //     });
            //   },
            //   items: _dropDownBlood,
            // ),
            // SizedBox(height: 15),
            // Text(
            //   'marital_status_dot'.tr(),
            //   style: kInputTextStyle,
            // ),
            // DropdownButton(
            //   isExpanded: true,
            //   value: _selectedMarital,
            //   //hint: ,
            //   onChanged: (String? value) {
            //     setState(() {
            //       _selectedMarital = value!;
            //     });
            //   },
            //   items: _dropDownMarital,
            // ),
            // SizedBox(height: 15),
            // Text(
            //   'height_dot'.tr(),
            //   style: kInputTextStyle,
            // ),
            // CustomTextFormField(
            //   keyboardType: TextInputType.number,
            //   hintText: 'in_cm'.tr(),
            // ),
            // SizedBox(height: 15),
            // Text(
            //   'weight_dot'.tr(),
            //   style: kInputTextStyle,
            // ),
            // CustomTextFormField(
            //   keyboardType: TextInputType.number,
            //   hintText: 'in_kg'.tr(),
            // ),

            if (isProcessing) ...[
              Container(
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              )
            ] else ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: CustomButton(
                  onPressed: () {
                    updateProfile(context);
                  },
                  text: 'update_info'.tr(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.camera,
                  size: 20,
                ),
                title: Text(
                  'take_a_photo'.tr(),
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  size: 20,
                ),
                title: Text(
                  'choose_a_photo'.tr(),
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          );
        });
  }
}

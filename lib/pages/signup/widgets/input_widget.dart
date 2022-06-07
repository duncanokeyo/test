import 'package:bridgemetherapist/AuthState.dart';
import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/components/custom_button.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../../../components/labeled_text_form_field.dart';
import '../../../utils/constants.dart';
import 'package:supabase/supabase.dart' as supabase1;

enum Gender { male, female }

class InputWidget extends StatefulWidget {
  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends AuthState<InputWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var processing = false;
  Gender _gender = Gender.male;

  Future _onSignUpPress(BuildContext context) async {
    setState(() {
      processing = true;
    });
    final form = _formKey.currentState;

    if (form != null && form.validate()) {
      form.save();

      if (_confirmPasswordController.text != _passwordController.text) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Passwords do not match")));
        setState(() {
          processing = false;
        });
      }
      String name =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
      String gender = "";
      if (_gender == Gender.male) {
        gender = "Male";
      } else {
        gender = "Female";
      }

      FocusScope.of(context).unfocus();
      final response = await supabase.auth.signUp(
          _emailController.text, _passwordController.text,
          options: supabase1.AuthOptions(
              redirectTo: 'io.supabase.flutterquickstart://login-callback/'),
          userMetadata: {'user_type': 2, 'user_name': name, 'gender': gender});
      setState(() {
        processing = false;
      });

      if (response.error != null) {
        showMessage('Sign up failed: ${response.error!.message}');
      } else if (response.data == null && response.user == null) {
        _showDialog();
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
      }
    } else {
      setState(() {
        processing = false;
      });
      showMessage("Error occured");
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Sign up success"),
          content: new Text(
              "Please check your email and follow the instructions to verify your email address."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(NavigationService.navigatorKey.currentState!.context)
        .showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LabeledTextFormField(
                  title: 'first_name_dot'.tr(),
                  controller: _firstNameController,
                  hintText: 'John',
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required"),
                    MinLengthValidator(2,
                        errorText:
                            "First name Length must be atleast 2 characters"),
                    MaxLengthValidator(100,
                        errorText:
                            "Firsst name length must not be more than 100 characters"),
                  ]),
                ),
                LabeledTextFormField(
                  title: 'last_name_dot'.tr(),
                  controller: _lastNameController,
                  hintText: 'Doe',
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required"),
                    MinLengthValidator(2,
                        errorText:
                            "Last name Length must be atleast 2 characters"),
                    MaxLengthValidator(100,
                        errorText:
                            "Last name length must not be more than 100 characters"),
                  ]),
                ),
                Text(
                  'gender_dot'.tr(),
                  style: kInputTextStyle,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                Radio(
                  value: Gender.male,
                  groupValue: _gender,
                  onChanged: (Gender? gender) {
                    setState(() {
                      _gender = gender!;
                    });
                  },
                ),
                Text(
                  'male'.tr(),
                  style: kInputTextStyle,
                ),
                SizedBox(
                  width: 30,
                ),
                Radio(
                  value: Gender.female,
                  groupValue: _gender,
                  onChanged: (Gender? gender) {
                    setState(() {
                      _gender = gender!;
                    });
                  },
                ),
                Text(
                  'female'.tr(),
                  style: kInputTextStyle,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LabeledTextFormField(
                    title: 'email_dot'.tr(),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'bhr.tawfik@gmail.com',
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Required"),
                      EmailValidator(
                          errorText: "Please enter a valid email address"),
                    ])),
                LabeledTextFormField(
                  title: 'password_dot'.tr(),
                  controller: _passwordController,
                  obscureText: true,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required"),
                    MinLengthValidator(6,
                        errorText:
                            "Password must contain atleast 6 characters"),
                    MaxLengthValidator(20,
                        errorText:
                            "Password must not be more than 20 characters"),
                  ]),
                  hintText: '* * * * * *',
                ),
                LabeledTextFormField(
                  title: 'confirm_password_dot'.tr(),
                  controller: _confirmPasswordController,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Required"),
                    MinLengthValidator(6,
                        errorText:
                            "Password must contain atleast 6 characters"),
                    MaxLengthValidator(20,
                        errorText:
                            "Password must not be more than 20 characters"),
                  ]),
                  obscureText: true,
                  hintText: '* * * * * *',
                ),
                const SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 38),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    child: Center(
                      child: processing
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            )
                          : CustomButton(
                              onPressed: () => _onSignUpPress(context),
                              text: 'sign_up'.tr(),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

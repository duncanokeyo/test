import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/components/custom_button.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';

import '../../../AuthState.dart';
import '../../../components/labeled_text_form_field.dart';
import '../../../routes/routes.dart';

class InputWidget extends StatefulWidget {
  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends AuthState<InputWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final box = Get.find<GetStorage>();

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
        .showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
              EmailValidator(errorText: "Please enter a valid email address"),
            ]),
          ),
          LabeledTextFormField(
            title: 'password_dot'.tr(),
            controller: _passwordController,
            obscureText: true,
            hintText: '* * * * * *',
            padding: 0,
            validator: MultiValidator([
              RequiredValidator(errorText: "Required"),
              MinLengthValidator(6,
                  errorText: "Password must contain atleast 6 characters"),
              MaxLengthValidator(20,
                  errorText: "Password must not be more than 20 characters"),
            ]),
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.forgotPassword);
                },
                child: Text(
                  'forgot_yout_password'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          processing
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                )
              : CustomButton(
                  onPressed: () {
                    // // Navigator.of(context)
                    // //     .popAndPushNamed(Routes.home);

                    // Navigator.of(context).pushNamed(Routes.questionnaire);

                    _onSignInPressed(context);
                  },
                  text: 'login'.tr(),
                ),
        ],
      ),
    );
  }

  var processing = false;
  Future _onSignInPressed(BuildContext context) async {
    final form = _formKey.currentState;
    setState(() {
      processing = true;
    });

    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

      ///check if this user is a therapist
      final isTherapistFetch = await supabase
          .from('profiles')
          .select('user_type')
          .eq('email', _emailController.text)
          .execute();
      if (isTherapistFetch.hasError) {
        setState(() {
          processing = false;
        });
        showMessage("Error signing in");
        return;
      }

      List<dynamic> data = isTherapistFetch.data;
      if (data.isEmpty) {
        setState(() {
          processing = false;
        });
        showMessage("User not found");
        return;
      }

      Map<String, dynamic> item = data[0];

      if (item["user_type"] != "2") {
        setState(() {
          processing = false;
        });
        showMessage("You are not a therapist");
        return;
      }

      final response = await supabase.auth.signIn(
          email: _emailController.text, password: _passwordController.text);

      if (response.error != null) {
        showMessage(response.error!.message);
        setState(() {
          processing = false;
        });
      } else {
        setState(() {
          processing = false;
        });

        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
      }
    } else {
      setState(() {
        processing = false;
      });
    }
  }
}

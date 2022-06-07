import 'package:bridgemetherapist/AuthState.dart';
import 'package:bridgemetherapist/components/wave_header.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/custom_button.dart';
import '../../components/text_form_field.dart';
import '../../utils/constants.dart';
import 'package:supabase/supabase.dart' as supabase1;
import 'package:flutter/foundation.dart' show kIsWeb;

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        WaveHeader(
                          title: 'BridgeME',
                        ),
                        Theme(
                          data: ThemeData(
                            appBarTheme: AppBarTheme(
                              iconTheme: IconThemeData(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          child: AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 20,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 38),
                            child: Center(
                              child: Text(
                                'Enter email for password reset',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          if (kIsWeb) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: WidgetForgot(),
                                  width: 300,
                                  height: 300,
                                ),
                              ],
                            ),
                          ] else ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 38),
                              child: WidgetForgot(),
                            ),
                          ],

                          Expanded(
                            child: SizedBox(
                              height: 20,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     elevation: 0,
    //     backgroundColor: Colors.transparent,
    //   ),
    //   body: LayoutBuilder(
    //     builder: (BuildContext context, BoxConstraints viewportConstraints) {
    //       return SingleChildScrollView(
    //         child: ConstrainedBox(
    //           constraints: BoxConstraints(
    //             minHeight: viewportConstraints.maxHeight,
    //           ),
    //           child: IntrinsicHeight(
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 0),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                    WaveHeader(
    //                       title: 'welcome_to_app_name'.tr(),
    //                     ),
    //                   Expanded(
    //                     child: SizedBox(
    //                       height: 80,
    //                     ),
    //                   ),
    //                   Text(
    //                     'forgot_password'.tr(),
    //                     style: TextStyle(
    //                       fontSize: 28,
    //                       fontWeight: FontWeight.w700,
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     height: 30,
    //                   ),
    //                   WidgetForgot(),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}

class WidgetForgot extends StatefulWidget {
  @override
  _WidgetForgotState createState() => _WidgetForgotState();
}

class _WidgetForgotState extends AuthState<WidgetForgot> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var processing = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'email_dot'.tr(),
            style: kInputTextStyle,
          ),
          CustomTextFormField(
            controller: _emailController,
            hintText: 'bhr.tawfik@gmail.com',
            validator: MultiValidator([
              RequiredValidator(errorText: "Required"),
              EmailValidator(errorText: "Please enter a valid email address"),
            ]),
          ),
          const SizedBox(
            height: 35,
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
                    _onRecoverPasswordPressed(context);
                  },
                  text: 'reset_password'.tr(),
                ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.login);
              },
              child: Text(
                'login'.tr(),
                style:
                    Theme.of(context).textTheme.button!.copyWith(fontSize: 12),
              ),
            ),
          ),
          // Expanded(
          //   flex: 2,
          //   child: SizedBox(
          //     height: 20,
          //   ),
          // ),
        ],
      ),
    );
  }

  void showMessage(BuildContext context, String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future _onRecoverPasswordPressed(BuildContext context) async {
    final form = _formKey.currentState;
    setState(() {
      processing = true;
    });
    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

      final response = await supabase.auth.api.resetPasswordForEmail(
          _emailController.text,
          options: supabase1.AuthOptions(
              redirectTo: 'io.supabase.flutterquickstart://login-callback/'));
      setState(() {
        processing = false;
      });
      if (response.error != null) {
        showMessage(
            context, 'Password recovery failed: ${response.error!.message}');
      } else {
        showMessage(
            context, 'Please check your email for further instructions.');
      }
    } else {
      setState(() {
        processing = false;
      });
      showMessage(context, 'Error occured');
    }
  }
}

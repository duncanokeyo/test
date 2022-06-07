import 'dart:collection';

import 'package:bridgemetherapist/components/custom_button.dart';
import 'package:bridgemetherapist/model/DiscussionCategories.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import '../../model/Profile.dart';
import '../../model/notification.dart';

class AddDiscussionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddDiscussionPageState();
  }
}

class _AddDiscussionPageState extends State<AddDiscussionPage> {
  late Profile profile;

  var categories = <DiscussionCategories>[];
  var isLoading = false;
  var processing = false;
  var errorProcessing = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController userNameController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  var categorySelected;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    setState(
      () {
        categories = discussionCategoriesFromMap(
            Get.find<GetStorage>().read('discussion_categories'));
        profile = profileFromMap(Get.find<GetStorage>().read('profile'))[0];

        userNameController.text = profile.username;
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  addDiscussion(context) async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

      setState(() {
        processing = true;
        errorProcessing = false;
      });

      if (categorySelected == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Select discussion category")));

        setState(() {
          processing = false;
          errorProcessing = false;
        });
        return;
      }
      String message = messageController.text;
      String userName = userNameController.text;

      //check for duplicate discussion;

      var duplicate = await supabase
          .from('chat_rooms')
          .select('message')
          .eq('message', message.toLowerCase())
          .execute();

      if (duplicate.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading discussion")));

        setState(() {
          processing = false;
        });
        return;
      } else {
        print(duplicate.toJson());
        if ((duplicate.data as List<dynamic>).isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Discussion already exists")));

          setState(() {
            processing = false;
          });
          return;
        }
      }
      Map<dynamic, dynamic> insert = HashMap();
      insert['username'] = userName;
      insert['message'] = message.toLowerCase();
      insert['avatar_url'] = profile.avatarUrl;
      insert['user_id'] = supabase.auth.currentUser!.id;
      insert['category_id'] = (categorySelected as DiscussionCategories).id;

      var insertResponse =
          await supabase.from('chat_rooms').insert(insert).execute();
      if (insertResponse.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading discussion")));

        setState(() {
          processing = false;
        });
        return;
      } else {
        setState(() {
          processing = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _txtStyle = TextStyle(
        fontSize: 15.5,
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontFamily: 'Gotik');
    return Scaffold(
      appBar: AppBar(
        title: Text('add_discussion'.tr()),
      ),
      body: isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                      padding: kIsWeb
                        ? const EdgeInsets.only(
                            left: WEBPADDING, right: WEBPADDING)
                        : const EdgeInsets.all(0.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: userNameController,
                          validator: (String? val) {
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: kColorDarkGreen, width: 1.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: kColorDarkGreen, width: 1.0),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            hintStyle: TextStyle(color: kColorDarkGreen),
                            labelStyle: TextStyle(color: kColorDarkGreen),
                            labelText: "username",
                            fillColor: Colors.white70,
                            alignLabelWithHint: true,
                            isDense: true,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        TextFormField(
                          controller: messageController,
                          validator: (String? val) {
                            if (val == null) {
                              return 'This field is required';
                            }
                            if (val.isEmpty) {
                              return 'This field is required';
                            }

                            return null;
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 10,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: kColorDarkGreen, width: 1.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: kColorDarkGreen, width: 1.0),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            hintStyle: TextStyle(color: kColorDarkGreen),
                            labelStyle: TextStyle(color: kColorDarkGreen),
                            labelText: "message",
                            fillColor: Colors.white70,
                            alignLabelWithHint: true,
                            isDense: true,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        
                        FormField<DiscussionCategories>(
                          builder: (FormFieldState<DiscussionCategories> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                  labelStyle: _txtStyle,
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent, fontSize: 16.0),
                                  hintText: 'Please select discussion category',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0))),
                              isEmpty: categorySelected == null,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<DiscussionCategories>(
                                  value: categorySelected,
                                  isDense: true,
                                  onChanged: (DiscussionCategories? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        categorySelected = newValue;
                                        state.didChange(newValue);
                                      });
                                    }
                                  },
                                  items: categories
                                      .map((DiscussionCategories value) {
                                    return DropdownMenuItem<DiscussionCategories>(
                                      value: value,
                                      child: Text(value.category),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (processing) ...[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(kColorDarkGreen),
                              ),
                            ),
                          )
                        ] else ...[
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            child: CustomButton(
                              onPressed: () {
                                addDiscussion(context);
                              },
                              text: 'Add discussion',
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

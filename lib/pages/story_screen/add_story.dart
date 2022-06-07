import 'dart:collection';
import 'dart:io';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/components/custom_button.dart';
import 'package:bridgemetherapist/components/day_item.dart';
import 'package:bridgemetherapist/components/time_slot_item.dart';
import 'package:bridgemetherapist/controller/JournalController.dart';
import 'package:bridgemetherapist/model/Posts.dart';
import 'package:bridgemetherapist/model/Profile.dart';
import 'package:bridgemetherapist/model/SessionStartEndTime.dart';
import 'package:bridgemetherapist/model/Slot.dart';
import 'package:bridgemetherapist/pages/journals/journal_list.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../extensions.dart';

class AddStory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddStoryState();
  }
}

class _AddStoryState extends State<AddStory> {
  final storage = FirebaseStorage.instance.ref();

  var _fetchingPost = false;
  var _errorFetchingPost = false;
  var _processing = false;
  var box = Get.find<GetStorage>();

  File? file;
  String? fileName;

  final TextEditingController _captionController = TextEditingController();
  String? _selectedMediaType;

  Post? post;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  _save(context) async {
    if (_selectedMediaType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select media type")));
      return;
    }
    if (_selectedMediaType == "text" && _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter caption")));
      return;
    }

    if ((_selectedMediaType == "video" || _selectedMediaType == "image") &&
        file == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select file")));
      return;
    }

    if (file != null) {
      VideoPlayerController fileVideocontroller =
          VideoPlayerController.file(file!)..initialize().then((value) {});

      debugPrint("========" + fileVideocontroller.value.duration.toString());
    }

    setState(() {
      _processing = true;
    });
    String uploadPath = "";
    if (file != null) {
      final bytes = await file!.readAsBytes();
      final fileName = Utils.getRandString(10);
      final photosReference = storage.child("posts/${fileName}");
      try {
        await photosReference.putData(bytes);
        uploadPath = await photosReference.getDownloadURL();
      } on Exception catch (e) {
    
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error uploading file")));
        setState(() {
          _processing = false;
        });
        return;
      }

      // try {
      //   final storageResponse = await supabase.storage
      //       .from('stories')
      //       .uploadBinary(fileName, bytes);

      //   if (storageResponse.hasError) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text("Error uploading image")));

      //     setState(() {
      //       _processing = false;
      //     });
      //   } else {
      //     final imageUrlResponse =
      //         supabase.storage.from('stories').getPublicUrl(fileName);
      //     if (imageUrlResponse.hasError) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text("Error uploading image")));
      //       setState(() {
      //         _processing = false;
      //       });
      //     } else {
      //       uploadPath = imageUrlResponse.data!;
      //     }
      //   }
      // } catch (e) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text("Error uploading file")));
      //   setState(() {
      //     _processing = false;
      //   });
      // }
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref("bridgeme/posts");
    Profile profile = profileFromMap(box.read('profile'))[0];

    await ref.push().set({
      "user_id": supabase.auth.currentUser!.id,
      "user_name": profile.username,
      "avatar_url": profile.avatarUrl,
      "mediaType": _selectedMediaType,
      "media": uploadPath,
      "post_id": Utils.getRandString(10),
      "duration": 50,
      "caption": _captionController.text,
      "when": DateTime.now().toIso8601String(),
      "color": "#d32f2f"
    });

    setState(() {
      _processing = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Saved post")));
    Navigator.of(context).pop();

    // PostElement element = PostElement(
    //   id: Utils.getRandString(10),
    //   when: DateTime.now(),
    //   caption: _captionController.text,
    //   media: uploadPath,
    //   color: "#d32f2f",
    //   mediaType: PostElement.getMediaType(_selectedMediaType),
    // );

    // if (post != null) {
    //   List<PostElement> elements = post!.posts;
    //   elements.add(element);

    //   var response = await supabase
    //       .from('posts')
    //       .update({
    //         'posts': List<dynamic>.from(elements.map((x) => x.toMap())),
    //       })
    //       .eq('id', post!.id)
    //       .execute();

    //   if (response.hasError) {
    //     setState(() {
    //       _processing = false;
    //     });
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(const SnackBar(content: Text("Error saving post")));
    //   } else {
    //     setState(() {
    //       _processing = false;
    //     });
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(const SnackBar(content: Text("Saved post")));
    //     Navigator.of(context).pop();
    //   }
    // } else {
    //   Profile profile = profileFromMap(box.read('profile'))[0];

    //   Map<String, dynamic> _insert = HashMap();
    //   _insert["user_id"] = supabase.auth.currentUser!.id;
    //   _insert["username"] = profile.username;
    //   _insert["posts"] = [element.toMap()];
    //   _insert["avatar_url"] = profile.avatarUrl;

    //   var response = await supabase.from('posts').insert(_insert).execute();

    //   if (response.hasError) {
    //     setState(() {
    //       _processing = false;
    //     });
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(const SnackBar(content: Text("Error saving post")));
    //   } else {
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(const SnackBar(content: Text("Saved post")));
    //     Navigator.of(context).pop();
    //   }
    // }
  }

  _selectFile(context) async {
    if (_selectedMediaType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select media type")));
      return;
    }

    FileType fileType = FileType.any;

    if (_selectedMediaType == "video") {
      fileType = FileType.video;
    } else if (_selectedMediaType == "image") {
      fileType = FileType.image;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
    );

    if (result != null) {
      int size = result.files.single.size;
      if (size == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not determine file Size")));
        return;
      }

      print(size);
      // if (size > 20000000) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text("Maximum upload size is 5 mb")));
      //   return;
      // }

      setState(() {
        file = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  _fetch() async {
    // setState(() {
    //   _fetchingPost = true;
    //   _errorFetchingPost = false;
    // });

    // var response = await supabase
    //     .from('posts')
    //     .select('*')
    //     .eq('user_id', supabase.auth.currentUser!.id)
    //     .execute();

    // print(response.toJson());

    // if (response.hasError) {
    //   setState(() {
    //     _fetchingPost = false;
    //     _errorFetchingPost = true;
    //   });
    //   return;
    // }

    // setState(() {
    //   _fetchingPost = false;
    //   _errorFetchingPost = false;
    // });

    // if ((response.data as List<dynamic>).isNotEmpty) {
    //   setState(() {
    //     post = postFromMap(response.data)[0];
    //   });
    // }
  }

  static const _txtStyle = TextStyle(
      fontSize: 15.5,
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontFamily: 'Gotik');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add post'),
      ),
      body: _fetchingPost
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _errorFetchingPost
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        _fetch();
                      },
                      child:
                          const Text("Error fetching presets, Tap to refresh"),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 20.0, bottom: 5.0, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text(
                              "Post type",
                              style: _txtStyle,
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                  labelStyle: _txtStyle,
                                  errorStyle: const TextStyle(
                                      color: Colors.redAccent, fontSize: 16.0),
                                  hintText: 'Please select post type',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              isEmpty: _selectedMediaType == null,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedMediaType,
                                  isDense: true,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedMediaType = newValue;

                                        state.didChange(newValue);
                                      });
                                    }
                                  },
                                  items: ["video", "image", "text"]
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          file = null;
                          fileName = null;
                          _selectFile(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 250,
                            child: Center(
                                child: Icon(
                              Icons.upload,
                              color: Colors.grey[400],
                              size: 40,
                            )),
                            color: Colors.grey[200],
                          ),
                        ),
                      ),
                      if (fileName != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                fileName!,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 20.0, bottom: 5.0, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text(
                              "Caption/content",
                              style: _txtStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: TextField(
                          minLines: 5,
                          maxLines: 10,
                          controller: _captionController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1.0),
                            ),
                            hintText: 'caption',
                          ),
                        ),
                      ),

                      if (!_processing) ...[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CustomButton(
                            text: "Save",
                            onPressed: () {
                              _save(context);
                            },
                          ),
                        )
                      ] else ...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      ]
                      // if (_startTime != null &&
                      //     _endTime != null &&
                      //     _selectedSlotSize != null) ...[
                      //   if (!_processing) ...[
                      // Padding(
                      //   padding: const EdgeInsets.all(10.0),
                      //   child: CustomButton(
                      //     text: "Save",
                      //     onPressed: () {
                      //       _save(context);
                      //     },
                      //   ),
                      // )
                      //   ] else ...[
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width,
                      //   height: 50,
                      //   child: const Center(
                      //     child: CircularProgressIndicator(),
                      //   ),
                      // )
                      //   ]
                      // ]
                    ],
                  ),
                ),
    );
  }
}

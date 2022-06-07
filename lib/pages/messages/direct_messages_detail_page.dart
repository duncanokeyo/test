import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/chat/widgets/chat.dart';
import 'package:bridgemetherapist/model/Channel.dart';
import 'package:bridgemetherapist/model/ChannelMessage.dart';
import 'package:bridgemetherapist/model/Profile.dart';
import 'package:bridgemetherapist/model/SessionBookings.dart';
import 'package:bridgemetherapist/pages/messages/CustomVideoRoomInitPage.dart';
import 'package:bridgemetherapist/pages/screeningtools/screening_tools_list.dart';
import 'package:bridgemetherapist/pages/sessionNotes/SessionNotesList.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:supabase_flutter/supabase_flutter.dart';

class DirectMessagesDetailPage extends StatefulWidget {
  // Channel channel;

  SessionBookings sessionBookings;

  DirectMessagesDetailPage({
    Key? key,
    required this.sessionBookings,
  }) : super(key: key);

  @override
  _DirectMessagesDetailPageState createState() =>
      _DirectMessagesDetailPageState();
}

class _DirectMessagesDetailPageState extends State<DirectMessagesDetailPage> {
  final _user = types.User(id: supabase.auth.currentUser!.id);
  List<types.Message> _messages = [];
  late Profile profile;
  var _isAttachmentUploading = false;

  bool checkingIfChannelExists = false;
  bool errorCheckingIfChannelExists = false;

  var channel;

  bool firstTimeLoadingMessages = false;

  var _loadingMessages = false;
  var _errorLoadingMessages = false;
  RealtimeSubscription? messagesSubscription;

  @override
  void initState() {
    super.initState();
    firstTimeLoadingMessages = true;
    _checkIfChannelExists();
    //check if this channel exists or not if it doesnt exist we check online
    //_loadMessages();
  }

  _openSessionNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionNotesList(
          patientId: widget.sessionBookings.patientId,
          therapistId: supabase.auth.currentUser!.id,
          //  sessionBookings: widget.sessionBookings,
        ),
      ),
    );
  }

  _checkIfChannelExists() async {
    profile = profileFromMap(Get.find<GetStorage>().read('profile'))[0];
    setState(() {
      checkingIfChannelExists = true;
      errorCheckingIfChannelExists = false;
    });
    var checkResponse = await supabase
        .from('channels')
        .select('*')
        .eq('therapist_id', supabase.auth.currentUser!.id)
        .eq('patient_id', widget.sessionBookings.patientId)
        .execute();

    print(checkResponse.toJson());
    if (checkResponse.hasError) {
      setState(() {
        checkingIfChannelExists = false;
        errorCheckingIfChannelExists = true;
      });
      return;
    }
    List<Channel> channels = channelFromMap(checkResponse.data);

    if (channels.isEmpty) {
      HashMap<String, dynamic> _insert = HashMap();
      _insert['patient_id'] = widget.sessionBookings.patientId;
      _insert['patient_avatar_url'] = widget.sessionBookings.avatarUrl;
      _insert['patient_name'] = widget.sessionBookings.username;
      _insert['therapist_id'] = supabase.auth.currentUser!.id;
      _insert['therapist_avatar_url'] = profile.avatarUrl;
      _insert['last_message_type'] = 'text';
      _insert['last_message'] = '';

      var timeStamp =
          "${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";
      _insert['last_message_timestamp'] = timeStamp;

      var insertResponse =
          await supabase.from('channels').insert(_insert).execute();
      print(insertResponse.toJson());
      if (insertResponse.hasError) {
        setState(() {
          checkingIfChannelExists = false;
          errorCheckingIfChannelExists = true;
        });
      } else {
        _checkIfChannelExists();
      }
    } else {
      setState(() {
        channel = channels[0];
        checkingIfChannelExists = false;
        errorCheckingIfChannelExists = false;
      });

      _loadMessages();
    }
  }

  @override
  void dispose() {
    if (messagesSubscription != null) {
      supabase.removeSubscription(messagesSubscription!);
    }
    super.dispose();
  }

  Future<void> _addMessage(types.Message message) async {
    if (!widget.sessionBookings.isPaid()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Client hasn't yet paid for the session")));
      return;
    }
    profile = profileFromMap(Get.find<GetStorage>().read('profile'))[0];

    print(message);

    String message_ = "";

    if (message is types.TextMessage) {
      message_ = message.text;
    } else {
      message_ = 'New message';
    }

    Map<String, dynamic> data = HashMap();
    Map<String, dynamic> notificaiton = HashMap();
    data["to"] = "/topics/${(channel as Channel).patientId}";
    notificaiton["title"] = profile.username;
    notificaiton["body"] = message_;

    data["notification"] = notificaiton;
    data["data"] = {'type': 'chat-message'};

    var insertResponse = await supabase.rpc('send_chat_message_rpc', params: {
      'channel_id_param': (channel as Channel).id,
      'type_param': "text",
      'avatar_url_param': profile.avatarUrl,
      'user_id_param': profile.id,
      'username_param': profile.username,
      'text_param': message_,
      'meta_param': null,
      'notification_param': jsonEncode(data)
    }).execute();

    //print(insertResponse.toJson());

    // Map<String, dynamic> _insert = HashMap();
    // _insert['channel_id'] = (channel as Channel).id;
    // _insert['type'] = "text";
    // _insert['avatar_url'] = profile.avatarUrl;
    // _insert['user_id'] = profile.id;
    // _insert['username'] = profile.username;
    // if (message is types.TextMessage) {
    //   _insert['text'] = message.text;
    // }

    //await supabase.from('channel_messages').insert(_insert).execute();
    // setState(() {
    // _messages.insert(0, message);
    //});
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                // TextButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //     _handleFileSelection();
                //   },
                //   child: const Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text('File'),
                //   ),
                // ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    // if (result != null && result.files.single.path != null) {
    //   final message = types.FileMessage(
    //     author: _user,
    //     createdAt: DateTime.now().millisecondsSinceEpoch,
    //     id: const Uuid().v4(),
    //     mimeType: lookupMimeType(result.files.single.path!),
    //     name: result.files.single.name,
    //     size: result.files.single.size,
    //     uri: result.files.single.path!,
    //   );

    //   _addMessage(message);
    // }
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  void _handleImageSelection() async {
    if (!widget.sessionBookings.isPaid()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Client hasn't yet paid for the session")));
      return;
    }
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);

      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final fileExt = result.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;

      try {
        final storageResponse =
            await supabase.storage.from('chat').uploadBinary(filePath, bytes);

        print(storageResponse.error?.message);
        if (storageResponse.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error uploading image")));
          _setAttachmentUploading(false);
        } else {
          final imageUrlResponse =
              supabase.storage.from('chat').getPublicUrl(filePath);
          // final message = types.ImageMessage(
          //   author: _user,
          //   createdAt: DateTime.now().millisecondsSinceEpoch,
          //   height: image.height.toDouble(),
          //   id: "",
          //   name: result.name,
          //   size: bytes.length,
          //   uri: result.path,
          //   width: image.width.toDouble(),
          // );

          Map<String, dynamic> _meta = HashMap();
          _meta["height"] = image.height.toDouble();
          _meta["name"] = fileName;
          _meta["size"] = bytes.length;
          _meta["uri"] = imageUrlResponse.data;
          _meta["width"] = image.width.toDouble();

          Map<String, dynamic> data = HashMap();
          Map<String, dynamic> notificaiton = HashMap();
          data["to"] = "/topics/${(channel as Channel).patientId}";
          notificaiton["title"] = profile.username;
          notificaiton["body"] = 'Attachment';
          data["notification"] = notificaiton;

          data["data"] = {'type': 'chat-message'};

          var insertResponse =
              await supabase.rpc('send_chat_message_rpc', params: {
            'channel_id_param': (channel as Channel).id,
            'type_param': "image",
            'avatar_url_param': profile.avatarUrl,
            'user_id_param': profile.id,
            'username_param': profile.username,
            'text_param': null,
            'meta_param': jsonEncode(_meta),
            'notification_param': jsonEncode(data)
          }).execute();

          //  Map<String, dynamic> _insert = HashMap();
          //  _insert['channel_id'] = (channel as Channel).id;
          //  _insert['type'] = "image";
          //  _insert['avatar_url'] = profile.avatarUrl;
          //  _insert['user_id'] = profile.id;
          //  _insert['username'] = profile.username;

          //   _insert["meta"] = jsonEncode(_meta);

          //     var insertResponse =
          //       await supabase.from('channel_messages').insert(_insert).execute();
          if (insertResponse.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error uploading image")));
            _setAttachmentUploading(false);
            supabase.storage.from('chats').remove([filePath]);
            return;
          }

          _setAttachmentUploading(false);
        }
      } finally {
        _setAttachmentUploading(false);
      }
    } else {
      _setAttachmentUploading(false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error uploading image")));
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: "",
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    setState(() {
      _loadingMessages = true;
      _errorLoadingMessages = false;
    });

    var fetch = await supabase
        .from('channel_messages')
        .select("*")
        .eq('channel_id', (channel as Channel).id)
        .order('created_at')
        .execute();
    if (fetch.hasError) {
      setState(() {
        _loadingMessages = false;
        _errorLoadingMessages = true;
      });
      return;
    }

    setState(() {
      _loadingMessages = false;
      _errorLoadingMessages = false;
    });
    _onMessagesLoaded(fetch.data);
  }

  void _attachMessagesListener() {
    messagesSubscription = supabase
        .from("channel_messages:channel_id=eq.${(channel as Channel).id}")
        .on(SupabaseEventTypes.delete, (payload) {
      //print(payload.oldRecord);
    }).on(SupabaseEventTypes.insert, (payload) {
      if (payload.newRecord != null) {
        var message = ChannelMessage.fromMap(payload.newRecord!);
        // print(message.toString());
        //_messages.add(types.Message.fromJson(message.chatFormat()));
        _messages = [
          types.Message.fromJson(message.chatFormat()),
          ..._messages
        ];

        //  print('messages is -----------');
        print(_messages);
        //  print('---------------------------------');
        setState(() {});
      }
    }).subscribe();
  }

  _onMessagesLoaded(items) {
    if (firstTimeLoadingMessages) {
      _attachMessagesListener();
    }

    firstTimeLoadingMessages = false;

    List<ChannelMessage> parse = channelMessagesFromMap(items);
    final messages =
        (parse).map((e) => types.Message.fromJson(e.chatFormat())).toList();
    setState(() {
      _messages = messages;
    });
  }

  _openScreeningTools() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreeningToolsList(
          patientId: channel.patientId,
          therapistId: channel.therapistId,
          patientAvatarUrl: channel.patientAvatarUrl,
          patientName: channel.patientName,
          therapistAvatarUrl: channel.therapistAvatarUrl,
          therapistName: channel.therapistName,
          // sessionBookings: currentBooking,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checkingIfChannelExists) {
      return Scaffold(
        body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (errorCheckingIfChannelExists) {
      return Scaffold(
        body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: InkWell(
            onTap: () {
              _checkIfChannelExists();
            },
            child: const Center(
              child: Text("Error occured, Tap to refresh"),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () async {
                    if (!widget.sessionBookings.isPaid()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Client hasnt yet paid for this session")));
                      return;
                    }
                    String errorMessage = Utils.isSessionInTimeRange(
                        widget.sessionBookings.dateBooked,
                        widget.sessionBookings.time,
                        widget.sessionBookings.slotSize);

                    if (errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(errorMessage)));
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomVideoRoomInitPage(
                          sessionBooking: widget.sessionBookings,
                          sessionId: widget.sessionBookings.id,
                          therapistId: supabase.auth.currentUser!.id,
                          time: widget.sessionBookings.time,
                          dateBooked: widget.sessionBookings.dateBooked,
                          slotSize: widget.sessionBookings.slotSize,
                          patientId: widget.sessionBookings.patientId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.video_call)),
            ),

            // Padding(
            //   padding: const EdgeInsets.all(20.0),
            //   child: InkWell(
            //     radius: 40,
            //     onTap: () async {
            //       if (!widget.sessionBookings.isPaid()) {
            //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //             content:
            //                 Text("Client hasnt yet paid for this session")));
            //         return;
            //       }

            //       String errorMessage = Utils.isSessionInTimeRange(
            //           widget.sessionBookings.dateBooked, widget.sessionBookings.time, widget.sessionBookings.slotSize);

            //       if (errorMessage.isNotEmpty) {
            //         ScaffoldMessenger.of(context)
            //             .showSnackBar(SnackBar(content: Text(errorMessage)));
            //         return;
            //       }

            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => CustomVideoRoomInitPage(
            //             sessionBooking: widget.sessionBookings,
            //             sessionId: widget.sessionBookings.id,
            //             therapistId: supabase.auth.currentUser!.id,
            //             time: widget.sessionBookings.time,
            //             dateBooked: widget.sessionBookings.dateBooked,
            //             slotSize: widget.sessionBookings.slotSize,
            //             patientId: widget.sessionBookings.patientId,
            //           ),
            //         ),
            //       );
            //       //  }
            //       //}
            //     },

            //     child: IconButton(onPressed: onPressed, icon: const Icon(Icons.video_call)),

            //     // child: const Icon(
            //     //   Icons.video_call,
            //     //   color: kColorDarkGreen,
            //     // ),
            //   ),
            // ),
          ],
          title: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                child: Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 50,
                        backgroundImage: imageProvider,
                      ),
                      imageUrl: (channel as Channel).patientAvatarUrl,
                      errorWidget: (contex, url, error) {
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: Image.network(
                            DEFUALT_USER_PROFILE,
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding: EdgeInsets.all(1),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                (channel as Channel).patientName,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ],
          ),

          // actions: <Widget>[
          //   IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.phone,
          //     ),
          //   ),
          //   IconButton(
          //     onPressed: () {
          //       Navigator.of(context).pushNamed(Routes.doctorProfile);
          //     },
          //     icon: Icon(
          //       Icons.info,
          //     ),
          //   )
          // ],
        ),
        body: Padding(
          padding: kIsWeb
              ? const EdgeInsets.only(left: WEBPADDING, right: WEBPADDING)
              : const EdgeInsets.all(8.0),
          child: _loadingMessages
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _errorLoadingMessages
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () {
                          _loadMessages();
                        },
                        child: const Center(
                          child: Text("Error loading messages tap to retry"),
                        ),
                      ),
                    )
                  : Chat(
                      isAttachmentUploading: _isAttachmentUploading,
                      messages: _messages,
                      onAttachmentPressed: _handleAtachmentPressed,
                      onMessageTap: _handleMessageTap,
                      onScreenToolsTapped: () {
                        _openScreeningTools();
                      },
                      onSessionNotesTapped: () {
                        _openSessionNotes();
                      },
                      usePreviewData: true,
                      onPreviewDataFetched: _handlePreviewDataFetched,
                      onSendPressed: _handleSendPressed,
                      user: _user,
                    ),
        ),
      );
    }
  }
}

class MessageItem extends StatelessWidget {
  final bool send;
  final String message;

  const MessageItem({Key? key, required this.send, required this.message})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: send ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Visibility(
          visible: !send,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              'assets/images/icon_man.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
              left: !send ? 5 : (MediaQuery.of(context).size.width / 2) - 80,
              right: send ? 5 : (MediaQuery.of(context).size.width / 2) - 80,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(send ? 20 : 0),
                bottomRight: Radius.circular(send ? 0 : 20),
              ),
              color: send ? Color(0xffeaf2fe) : Colors.blue,
            ),
            child: SelectableText(
              message,
              style: TextStyle(
                color: send ? Colors.blue : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Visibility(
          visible: send,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              'assets/images/icon_man.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }
}

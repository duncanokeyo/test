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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:open_file/open_file.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/constants.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessagesDetailPage extends StatefulWidget {
  Channel channel;

  MessagesDetailPage({required this.channel});
  @override
  _MessagesDetailPageState createState() => _MessagesDetailPageState();
}

class _MessagesDetailPageState extends State<MessagesDetailPage> {
  final _user = types.User(id: supabase.auth.currentUser!.id);
  List<types.Message> _messages = [];
  late Profile profile;
  var _isAttachmentUploading = false;

  List<SessionBookings> activeSessions = [];
  bool checkedForActiveSessions = false;
  bool firstTimeLoadingMessages = false;
  RealtimeSubscription? messagesSubscription;

  var _loadingMessages = false;
  var _errorLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    firstTimeLoadingMessages = true;
    _loadMessages();
  }

  @override
  void dispose() {
    if (messagesSubscription != null) {
      supabase.removeSubscription(messagesSubscription!);
    }
    super.dispose();
  }

  _openScreeningTools() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreeningToolsList(
          patientId: widget.channel.patientId,
          therapistId: widget.channel.therapistId,
          patientAvatarUrl: widget.channel.patientAvatarUrl,
          patientName: widget.channel.patientName,
          therapistAvatarUrl: widget.channel.therapistAvatarUrl,
          therapistName: widget.channel.therapistName,
          // sessionBookings: currentBooking,
        ),
      ),
    );
  }

  _openSessionNotes() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionNotesList(
          patientId: widget.channel.patientId,
          therapistId: widget.channel.therapistId,
          // sessionBookings: currentBooking,
        ),
      ),
    );
  }

  Future<bool> _fetchActiveSessions() async {
    if (activeSessions.isEmpty && checkedForActiveSessions == false) {
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(max: 100, msg: 'Getting current session');
      var response = await supabase.rpc("active_sessions_therapist", params: {
        'therapist_id_param': supabase.auth.currentUser!.id,
        'patient_id_param': widget.channel.patientId
      }).execute();
      if (response.hasError) {
        pd.close();
        return false;
      }
      activeSessions = sessionBookingsFromMap(response.data);
      activeSessions.forEach(
        (element) {
          element.patientId = widget.channel.patientId;
        },
      );
      print(activeSessions);
      checkedForActiveSessions = true;
      pd.close();
      return true;
    }
    return true;
  }

  Future<void> _addMessage(types.Message message) async {
    var fetch = await _fetchActiveSessions();
    if (!fetch) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching active sessions")));
      return;
    }
    SessionBookings? currentBooking =
        Utils.currentBooking(activeSessions, null);

    if (currentBooking == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No active session")));
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
    data["to"] = "/topics/${widget.channel.patientId}";
    notificaiton["title"] = profile.username;
    notificaiton["body"] = message_;

    data["notification"] = notificaiton;
    data["data"] = {'type': 'chat-message'};

    var insertResponse = await supabase.rpc('send_chat_message_rpc', params: {
      'channel_id_param': widget.channel.id,
      'type_param': "text",
      'avatar_url_param': profile.avatarUrl,
      'user_id_param': profile.id,
      'username_param': profile.username,
      'text_param': message_,
      'meta_param': null,
      'notification_param': jsonEncode(data)
    }).execute();

    print(insertResponse.toJson());

    // Map<String, dynamic> _insert = HashMap();
    // _insert['channel_id'] = widget.channel.id;
    // _insert['type'] = "text";
    // _insert['avatar_url'] = profile.avatarUrl;
    // _insert['user_id'] = profile.id;
    // _insert['username'] = profile.username;
    // if (message is types.TextMessage) {
    //   _insert['text'] = message.text;
    // }

    // await supabase.from('channel_messages').insert(_insert).execute();
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
    var fetch = await _fetchActiveSessions();
    if (!fetch) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching active sessions")));
      return;
    }
    SessionBookings? currentBooking =
        Utils.currentBooking(activeSessions, null);

    if (currentBooking == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No active session")));
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

          // Map<String, dynamic> _insert = HashMap();
          // _insert['channel_id'] = widget.channel.id;
          // _insert['type'] = "image";
          // _insert['avatar_url'] = profile.avatarUrl;
          // _insert['user_id'] = profile.id;
          // _insert['username'] = profile.username;

          // Map<String, dynamic> _meta = HashMap();
          // _meta["height"] = image.height.toDouble();
          // _meta["name"] = fileName;
          // _meta["size"] = bytes.length;
          // _meta["uri"] = imageUrlResponse.data;
          // _meta["width"] = image.width.toDouble();

          // _insert["meta"] = jsonEncode(_meta);

          // var insertResponse =
          //     await supabase.from('channel_messages').insert(_insert).execute();

          Map<String, dynamic> _meta = HashMap();
          _meta["height"] = image.height.toDouble();
          _meta["name"] = fileName;
          _meta["size"] = bytes.length;
          _meta["uri"] = imageUrlResponse.data;
          _meta["width"] = image.width.toDouble();

          Map<String, dynamic> data = HashMap();
          Map<String, dynamic> notificaiton = HashMap();
          data["to"] = "/topics/${widget.channel.patientId}";
          notificaiton["title"] = profile.username;
          notificaiton["body"] = 'Attachment';
          data["notification"] = notificaiton;

          data["data"] = {'type': 'chat-message'};

          var insertResponse =
              await supabase.rpc('send_chat_message_rpc', params: {
            'channel_id_param': widget.channel.id,
            'type_param': "image",
            'avatar_url_param': profile.avatarUrl,
            'user_id_param': profile.id,
            'username_param': profile.username,
            'text_param': null,
            'meta_param': jsonEncode(_meta),
            'notification_param': jsonEncode(data)
          }).execute();

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

  void _attachMessagesListener() {
    messagesSubscription = supabase
        .from("channel_messages:channel_id=eq.${widget.channel.id}")
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

  void _loadMessages() async {
    setState(() {
      _loadingMessages = true;
      _errorLoadingMessages = false;
    });

    var fetch = await supabase
        .from('channel_messages')
        .select("*")
        .eq('channel_id', widget.channel.id)
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

  _onMessagesLoaded(items) {
    if (firstTimeLoadingMessages) {
      _attachMessagesListener();
    }

    firstTimeLoadingMessages = false;
    List<ChannelMessage> parse = channelMessagesFromMap(items);
    print('messages loaded ${parse.length}');
    final messages =
        (parse).map((e) => types.Message.fromJson(e.chatFormat())).toList();
    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () async {
                  var fetch = await _fetchActiveSessions();
                  if (!fetch) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Error fetching active sessions")));
                    return;
                  }
                  SessionBookings? currentBooking =
                      Utils.currentBooking(activeSessions, null);

                  if (currentBooking == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No active session")));
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomVideoRoomInitPage(
                        sessionId: currentBooking.id,
                        time: currentBooking.time,
                        sessionBooking: currentBooking,
                        slotSize: currentBooking.slotSize,
                        dateBooked: currentBooking.dateBooked,
                        patientId: widget.channel.patientId,
                        therapistId: widget.channel.therapistId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.video_call)),
          )
        ],
        title: Row(
          children: <Widget>[
            SizedBox(
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
                    imageUrl: widget.channel.patientAvatarUrl,
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              widget.channel.patientName,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
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
                    showSessionNotes: true,
                    showScreeningTools: true,
                    onScreenToolsTapped: () {
                      _openScreeningTools();
                    },
                    onSessionNotesTapped: () {
                      _openSessionNotes();
                    },
                    onAttachmentPressed: _handleAtachmentPressed,
                    onMessageTap: _handleMessageTap,
                    usePreviewData: true,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    onSendPressed: _handleSendPressed,
                    user: _user,
                  ),
      ),
    );
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
              'assets/images/icon_doctor_1.png',
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
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(send ? 20 : 0),
                bottomRight: Radius.circular(send ? 0 : 20),
              ),
              color: send ? const Color(0xffeaf2fe) : kColorGreen,
            ),
            child: SelectableText(
              message,
              style: TextStyle(
                color: send ? kColorDarkGreen : Colors.white,
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

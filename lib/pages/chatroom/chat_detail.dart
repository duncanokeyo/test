import 'dart:collection';


import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/ChatRoom.dart';
import 'package:bridgemetherapist/model/ChatRoomReplies.dart';
import 'package:bridgemetherapist/model/DiscussionCategories.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:readmore/readmore.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../utils/constants.dart';

class ChatRoomDetailPage extends StatefulWidget {
  ChatRoom chatRoom;
  ChatRoomDetailPage({required this.chatRoom});

  @override
  _ChatRoomDetailPageState createState() => _ChatRoomDetailPageState();
}

class _ChatRoomDetailPageState extends State<ChatRoomDetailPage> {
  @override
  void initState() {
    super.initState();

    setState(() {
      categories = discussionCategoriesFromMap(
          Get.find<GetStorage>().read('discussion_categories'));
    });

    fetch();
  }

  TextEditingController messageContoller = TextEditingController();

  var sendingMessage = false;
  var errorSendingMessage = false;
  var fetching = false;
  var errorFetching = false;
  var comments = <ChatRoomReplies>[];
  var categories = <DiscussionCategories>[];

  sendMessage(context) async {
    String message = messageContoller.text;
    if (message.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Empty message")));
      setState(() {
        sendingMessage = false;
      });
      return;
    }

    setState(() {
      sendingMessage = true;
    });

    Map<dynamic, dynamic> insert = HashMap();
    insert['reply'] = message;
    insert['user_id'] = supabase.auth.currentUser!.id;
    insert['chat_room_id'] = widget.chatRoom.id;

    var response =
        await supabase.from('chat_room_replies').insert(insert).execute();

    if (response.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error sending reply")));
      setState(() {
        sendingMessage = false;
      });
      return;
    }

    var response1 = await supabase
        .from('chat_room_replies')
        .select('id,reply,user_id,profiles(username,avatar_url)')
        .eq('chat_room_id', widget.chatRoom.id)
        .execute();

    if (response1.hasError) {
      return;
    }
    if ((response1.data as List<dynamic>).isNotEmpty) {
      messageContoller.text = "";
      setState(() {
        sendingMessage = false;

        comments = chatRoomRepliesFromMap(response1.data);
      });
    }
  }

  deleteComment(context, commentId) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'Deleting replay ..');

    var response = await supabase
        .from('chat_room_replies')
        .delete()
        .eq('id', commentId)
        .execute();
    print(response.toJson());
    if (response.hasError) {
      pd.close();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting reply")));
      return;
    }
    pd.close();

    setState(() {
      comments = comments.where((element) => element.id != commentId).toList();
    });
  }

  fetch() async {
    setState(() {
      fetching = true;
    });

    var response = await supabase
        .from('chat_room_replies')
        .select('id,reply,user_id,profiles(username,avatar_url)')
        .eq('chat_room_id', widget.chatRoom.id)
        .execute();

    if (response.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching comments")));

      setState(() {
        fetching = false;
      });
      return;
    }
    if ((response.data as List<dynamic>).isNotEmpty) {
      setState(() {
        comments = chatRoomRepliesFromMap(response.data);
      });
    }
    print(comments);
    setState(() {
      fetching = false;
    });
    print(response.toJson());
  }

  deleteChat() async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'Deleting discussion');

    var deleteCommentsResponse = await supabase
        .from('chat_room_replies')
        .delete()
        .eq('chat_room_id', widget.chatRoom.id)
        .execute();

    if (deleteCommentsResponse.hasError) {
      pd.close();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting discussion")));
      return;
    }
    var deletingChatRoom = await supabase
        .from('chat_rooms')
        .delete()
        .eq('id', widget.chatRoom.id)
        .execute();

    if (deletingChatRoom.hasError) {
      pd.close();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting discussion")));
      return;
    }
    pd.close();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (fetching) {
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (errorFetching) {
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: InkWell(
              onTap: () {
                fetch();
              },
              child: const Text("Error fetching comments. Tap to retry"),
            ),
          ),
        ),
      );
    } else {
      const _txtStyle = TextStyle(
          fontSize: 15.5,
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontFamily: 'Gotik');

      return Scaffold(
        appBar: AppBar(
          title: Text("Comments"),
          actions: [
            if (widget.chatRoom.userId == supabase.auth.currentUser!.id) ...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    Widget okButton = TextButton(
                      child: Text("Delete"),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        deleteChat();
                      },
                    );

                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: Text("Delete discussion"),
                      content:
                          Text("Are you sure you want to delete this comment?"),
                      actions: [
                        okButton,
                      ],
                    );
                    // show the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  },
                  child: const Icon(
                    Icons.delete,
                    color: kColorDarkGreen,
                  ),
                ),
              )
            ]
          ],
        ),
        body: Padding(
             padding: kIsWeb
              ? const EdgeInsets.only(left: WEBPADDING, right: WEBPADDING)
              : const EdgeInsets.all(15.0),
              
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CachedNetworkImage(
                                  width: 30,
                                  height: 30,
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                    radius: 30,
                                    backgroundImage: imageProvider,
                                  ),
                                  imageUrl: widget.chatRoom.avatarUrl,
                                  errorWidget: (contex, url, error) {
                                    return CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.transparent,
                                      child: Image.asset(
                                        'assets/images/icon_doctor_1.png',
                                        fit: BoxFit.fill,
                                      ),
                                    );
                                  },
                                ),
                                title: Text(
                                  widget.chatRoom.userName,
                                  style: _txtStyle,
                                ),
                                subtitle: Text(
                                  Utils.getTimeAgo(widget.chatRoom.createdAt),
                                ),
                                trailing: categories.isEmpty
                                    ? Container(
                                        width: 0,
                                      )
                                    : FilterChip(
                                        shape: const RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: kColorDarkGreen),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        label: Text(
                                            "${Utils.discussionCategory(categories, widget.chatRoom.categoryID)}"),
                                        backgroundColor: Colors.transparent,
                                        onSelected: (bool value) {},
                                      ),
                              ),
                              ReadMoreText(
                                Utils.upperCaseFirstLetter(
                                    widget.chatRoom.message.toLowerCase()),
                                trimLines: 5,
                                style: _txtStyle,
                                colorClickableText: kColorDarkGreen,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'Show more',
                                trimExpandedText: 'Show less',
                                lessStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kColorDarkGreen),
                                moreStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kColorDarkGreen),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Comments",
                          style: TextStyle(
                              fontSize: 15.5,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gotik'),
                        ),
                      ),
                      ...List.generate(comments.length, (index) {
                        ChatRoomReplies replies = comments[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MessageItem(
                            delete: (commentId) {
                              deleteComment(context, commentId);
                            },
                            send:
                                replies.userId == supabase.auth.currentUser!.id,
                            message: replies.reply,
                            commentId: replies.id,
                            avatarUrl: replies.profiles.avatarUrl,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!, width: 0.5),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: messageContoller,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[250],
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            hintText: 'Enter message',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                          ),
                          autofocus: false,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          cursorWidth: 1,
                        ),
                      ),
                      if (sendingMessage) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator()),
                        )
                      ] else ...[
                        IconButton(
                          onPressed: () {
                            sendMessage(context);
                          },
                          icon: Icon(
                            Icons.send,
                            size: 25,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

void showDeleteDialog(BuildContext context, Function onDeletePressed) {
  //final AuthController authController = Get.find<AuthController>();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
          "Delete comment?",
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text("Are you sure you want to delete this discussion?",
            style: Theme.of(context).textTheme.subtitle1),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Yes",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              onDeletePressed();
            },
          ),
          TextButton(
            child: Text(
              "No",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class MessageItem extends StatelessWidget {
  final bool send;
  final int commentId;
  final String message;
  String avatarUrl;
  Function delete;

  MessageItem(
      {Key? key,
      required this.commentId,
      required this.send,
      required this.message,
      required this.avatarUrl,
      required this.delete})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        if (send) {
          showDeleteDialog(context, () {
            delete(commentId);
          });
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            send ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: !send,
            child: CachedNetworkImage(
              width: 18,
              height: 18,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 18,
                backgroundImage: imageProvider,
              ),
              imageUrl: avatarUrl,
              errorWidget: (contex, url, error) {
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'assets/images/icon_doctor_1.png',
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: !send ? 5 : (MediaQuery.of(context).size.width / 2) - 80,
                right: send ? 5 : (MediaQuery.of(context).size.width / 2) - 80,
              ),
              padding: EdgeInsets.symmetric(
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
                color: send ? Color(0xffeaf2fe) : kColorGreen,
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
            child: CachedNetworkImage(
              width: 18,
              height: 18,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 18,
                backgroundImage: imageProvider,
              ),
              imageUrl: avatarUrl,
              errorWidget: (contex, url, error) {
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'assets/images/icon_doctor_1.png',
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

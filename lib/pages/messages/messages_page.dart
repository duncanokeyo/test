import 'dart:async';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/pages/messages/messages_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/Channel.dart';
import '../../routes/routes.dart';
import '../../utils/constants.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with AutomaticKeepAliveClientMixin<MessagesPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  StreamSubscription? subscription;

  var isFetching = false;
  var channels = <Channel>[];
  var filter = <Channel>[];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_search);
    _subscribe();
  }

  _subscribe() {
    setState(() {
      isFetching = true;
    });

    subscription = supabase
        .from("channels:therapist_id=eq.${supabase.auth.currentUser!.id}")
        .stream(['id'])
        .order('created_at')
        .execute()
        .listen(_onChannelsReceived);
  }

  _search() {
    String text = searchController.text;
    if (text.isEmpty) {
      setState(() {
        filter = channels;
      });
    } else {
      setState(() {
        filter = channels
            .where(
              (element) => (element.patientName
                  .toLowerCase()
                  .contains(text.toLowerCase())||element.lastMessage.toLowerCase().contains(text.toLowerCase())),
            )
            .toList();
      });
    }
  }

  _refresh() {
    subscription?.cancel();
    _subscribe();
  }

  @override
  void dispose() {
    searchController.dispose();
    subscription?.cancel();
    super.dispose();
  }

  _onChannelsReceived(items) {
    print(items);
    setState(() {
      isFetching = false;
      channels = channelFromMap(items);
    });
    _search();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: kColorGreen, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
              ),
              filled: true,
              fillColor: Colors.grey[250],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[400],
                size: 20,
              ),
              hintText: 'search_messages'.tr(),
              hintStyle: TextStyle(
                color: Colors.grey[400],
              ),
            ),
            cursorWidth: 1,
            maxLines: 1,
          ),
        ),
      ),
      body: isFetching
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : (!isFetching && filter.isEmpty)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: Text("No chats"),
                  ),
                )
              : SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: false,
                  onRefresh: () {
                    _refresh();
                    _refreshController.refreshCompleted();
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ...List.generate(
                          filter.length,
                          (index) {
                            Channel channel = filter[index];
                            return MessageListItem(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessagesDetailPage(
                                      channel: channel,
                                    ),
                                  ),
                                );
                              },
                              imagePath: channel.patientAvatarUrl,
                              name: channel.patientName,
                              message: channel.lastMessage == null
                                  ? channel.lastMessageType
                                  : channel.lastMessage!,
                              date: Utils.getTimeAgo(channel.lastMessageTime),
                              unread: 0,
                              online: false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MessageListItem extends StatelessWidget {
  final void Function() onTap;
  final String imagePath;
  final String name;
  final String message;
  final String date;
  final int? unread;
  final bool online;

  const MessageListItem({
    Key? key,
    required this.onTap,
    required this.imagePath,
    required this.name,
    required this.message,
    required this.date,
    this.unread,
    required this.online,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    width: 50,
                    height: 50,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 50,
                      backgroundImage: imageProvider,
                    ),
                    imageUrl: imagePath,
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
                  Visibility(
                    visible: online,
                    child: Align(
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
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    Utils.stripMessage(message),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  date,
                  style: const TextStyle(
                    color: kColorDarkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Visibility(
                  visible: (unread != 0 && unread != null) ? true : false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: kColorPrimary,
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

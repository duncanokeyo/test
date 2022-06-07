import 'dart:async';

import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/model/ChatRoom.dart';
import 'package:bridgemetherapist/model/DiscussionCategories.dart';
import 'package:bridgemetherapist/pages/chatroom/chat_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:filter_list/filter_list.dart';

import '../../routes/routes.dart';
import '../../utils/constants.dart';

class ChatRoomPage extends StatefulWidget {
  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
    with AutomaticKeepAliveClientMixin<ChatRoomPage> {
  StreamSubscription? subscription;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  var chatRooms = <ChatRoom>[];
  var filterRooms = <ChatRoom>[];
  var categories = <DiscussionCategories>[];
  var filterCategories = <DiscussionCategories>[];

  var isFetching = false;
  var errorFetching = false;

  filter() {
    if (filterCategories.isEmpty) {
      setState(() {
        filterRooms = chatRooms;
      });
    } else {
      List<int> categoriesIds = [];
      filterCategories.forEach((element) {
        categoriesIds.add(element.id);
      });

      setState(() {
        filterRooms = chatRooms
            .where((element) => categoriesIds.indexOf(element.categoryID) != -1)
            .toList();
      });
      // List<ChatRoom> filter = chatRooms
      //     .where((element) => categoriesIds.indexOf(element.categoryID) != -1)
      //     .toList();
      // setState(() {
      //   filterRooms = filter;
      // });
    }
  }

  _refresh() {
    setState(() {
      isFetching = true;
    });
    subscription?.cancel();

    subscription = supabase
        .from('chat_rooms')
        .stream([
          'chat_rooms.created_at,user_id,message,category_id,profiles(username,avatar_url),discussion_categories(category)'
        ])
        .order('created_at', ascending: true)
        .execute()
        .listen(_onChatsReceived);
  }

  subscribe() async {
    setState(() {
      isFetching = true;
    });

    categories = discussionCategoriesFromMap(
        Get.find<GetStorage>().read('discussion_categories'));

    if (chatRooms.isNotEmpty) {
      setState(() {
        isFetching = false;
      });
      return;
    }

    subscription ??= supabase
        .from('chat_rooms')
        .stream([
          'chat_rooms.created_at,user_id,message,category_id,profiles(username,avatar_url),discussion_categories(category)'
        ])
        .order('created_at', ascending: false)
        .execute()
        .listen(_onChatsReceived);
  }

  _onChatsReceived(items) {
    List<ChatRoom> chatRooms = chatRoomFromMap(items);
    filterRooms.clear();
    setState(() {
      isFetching = false;
      this.chatRooms = chatRooms;
    });

    filter();
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _txtStyle = TextStyle(
        fontSize: 15.5,
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontFamily: 'Gotik');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            height: 50,
            child: Row(
              children: [
                Text("Filter Category",
                    style: TextStyle(
                        fontSize: 15.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gotik')),
                Spacer(),
                InkWell(
                  onTap: () async {
                    await FilterListDialog.display<DiscussionCategories>(
                      context,
                      themeData: FilterListThemeData(context,
                          choiceChipTheme: ChoiceChipThemeData(
                              selectedBackgroundColor: kColorDarkGreen),
                          controlButtonBarTheme: ControlButtonBarThemeData(
                              controlButtonTheme: ControlButtonThemeData(
                                  textStyle: TextStyle(color: kColorDarkGreen),
                                  primaryButtonBackgroundColor:
                                      kColorDarkGreen))),
                      listData: categories,
                      selectedListData: filterCategories,
                      choiceChipLabel: (category) => category!.category,
                      validateSelectedItem: (list, val) => list!.contains(val),
                      onItemSearch: (category, query) {
                        return category.category!
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      },
                      onApplyButtonClick: (list) {
                        setState(() {
                          filterCategories.clear();
                          filterCategories = List.from(list!);
                        });
                        filter();
                        Navigator.pop(context);
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: Image.asset(
                        'assets/images/filter.png',
                        color: kColorDarkGreen,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: () {
              _refresh();
              _refreshController.refreshCompleted();
            },
            child: Column(
              children: [
                if (isFetching) ...[
                  Expanded(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ))
                ] else if (!isFetching && filterRooms.isEmpty) ...[
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text("No chats rooms"),
                      ),
                    ),
                  )
                ] else ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: filterRooms.length,
                        itemBuilder: (BuildContext context, int index) {
                          ChatRoom chatRoom = filterRooms[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomDetailPage(
                                    chatRoom: chatRoom,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.grey[50],
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: CachedNetworkImage(
                                        width: 30,
                                        height: 30,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                          radius: 30,
                                          backgroundImage: imageProvider,
                                        ),
                                        imageUrl: chatRoom.avatarUrl,
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
                                        chatRoom.userName,
                                        style: _txtStyle,
                                      ),
                                      subtitle: Text(
                                        Utils.getTimeAgo(chatRoom.createdAt),
                                      ),
                                      trailing: categories.isEmpty
                                          ? Container(
                                              width: 0,
                                            )
                                          : FilterChip(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color:
                                                              kColorDarkGreen),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                              label: Text(
                                                  "${Utils.discussionCategory(categories, chatRoom.categoryID)}"),
                                              backgroundColor:
                                                  Colors.transparent,
                                              onSelected: (bool value) {},
                                            ),
                                    ),
                                    ReadMoreText(
                                      Utils.upperCaseFirstLetter(
                                          chatRoom.message.toLowerCase()),
                                      trimLines: 2,
                                      style: _txtStyle,
                                      colorClickableText: kColorDarkGreen,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'Show more',
                                      trimExpandedText: 'Show less',
                                      lessStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: kColorDarkGreen),
                                      moreStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: kColorDarkGreen),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    if (chatRoom.commentCount > 0) ...[
                                      Divider(
                                        color: Colors.grey[200],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.chat_sharp,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "${chatRoom.commentCount} comments",
                                            style: TextStyle(
                                                color: Colors.grey[400]),
                                          )
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

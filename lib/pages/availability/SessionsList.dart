import 'dart:async';

import 'package:bridgemetherapist/model/Articles.dart';
import 'package:bridgemetherapist/model/Sessions.dart';
import 'package:bridgemetherapist/pages/article/article_detail.dart';
import 'package:bridgemetherapist/pages/availability/EditAvailability.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controller/ArticlesController.dart';

class SessionsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SessionsListState();
  }
}

class SessionsListState extends State<SessionsList> {
  var _fetchingSessions = false;
  var _errorFetchingSessions = false;
  StreamSubscription? subscription;
  var sessions = <Sessions>[];
  var filter = <Sessions>[];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_search);

    _subscribe();
  }

  _search() {
    String text = searchController.text;
    if (text.isEmpty) {
      setState(() {
        filter = sessions;
      });
    } else {
      setState(() {
        filter = sessions
            .where(
              (element) => (element
                  .formatTimeRange()
                  .toLowerCase()
                  .contains(text.toLowerCase())),
            )
            .toList();
      });
    }
  }

  _subscribe() {
    setState(() {
      _fetchingSessions = true;
      _errorFetchingSessions = false;
    });

    subscription = supabase
        .from("sessions:therapist_id=eq.${supabase.auth.currentUser!.id}")
        .stream(['id'])
        .order('created_at')
        .execute()
        .listen(_onSessionsReceived);
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  _refresh() {
    subscription?.cancel();
    _subscribe();
  }

  _onSessionsReceived(event) {
    setState(() {
      _fetchingSessions = false;
      _errorFetchingSessions = false;
      sessions = sessionsFromMap(event);
      filter = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        title: Column(
          children: [
           const Text('Sessions'),
            const SizedBox(
              height: 5,
            ),
            Padding(
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
                    borderSide:
                        BorderSide(color: Colors.grey[300]!, width: 0.5),
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
                  hintText: 'Search sessions',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
                cursorWidth: 1,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kColorDarkGreen,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.availability);
        },
        icon: const Icon(Icons.calendar_month),
        label: const Text("Add session"),
      ),
      body: _fetchingSessions
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _errorFetchingSessions
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        _refresh();
                      },
                      child: const Text(
                          "Error fetching time slots, Tap to refresh"),
                    ),
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
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        Sessions item = filter[index];
                        return ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditAvailability(session: item),
                              ),
                            );
                          },
                          title: Text(item.formatTimeRange()),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: kColorDarkGreen,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.grey,
                        );
                      },
                      itemCount: filter.length),
                ),
    );
  }
}

import 'dart:async';

import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/model/Articles.dart';
import 'package:bridgemetherapist/model/Posts.dart';
import 'package:bridgemetherapist/model/Sessions.dart';
import 'package:bridgemetherapist/pages/article/article_detail.dart';
import 'package:bridgemetherapist/pages/availability/EditAvailability.dart';
import 'package:bridgemetherapist/pages/story_screen/story_view_individual.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../controller/ArticlesController.dart';

class StoryList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StoryListState();
  }
}

class StoryListState extends State<StoryList> {
  var _fetching = false;
  var _errorFetching = false;
  // StreamSubscription? subscription;
//  Post? post;

  var posts = <PostElement>[];
  DatabaseReference ref = FirebaseDatabase.instance.ref("bridgeme/posts");
  StreamSubscription<DatabaseEvent> ?event;
  @override
  void initState() {
    super.initState();
//    _subscribe();

    event= ref
        // equalTo(supabase.auth.currentUser!.id,key: "user_id").
        .orderByChild('user_id')
        .equalTo(supabase.auth.currentUser!.id)
        .onValue
        .listen((event) {
      _onPostsReceived(event);
    }, onError: (error) {
      // Error.
    });

    // ref
    //     //.equalTo(supabase.auth.currentUser!.id, key: "user_id")
    //     .onValue
    //     .listen(_onPostsReceived, onError: () {}, onDone: () {});
  }

  // _subscribe() {
  //   setState(() {
  //     _fetching = true;
  //     _errorFetching = false;
  //   });

  //   subscription = supabase
  //       .from("posts:user_id=eq.${supabase.auth.currentUser!.id}")
  //       .stream(['id'])
  //       .order('created_at')
  //       .execute()
  //       .listen(_onPostsReceived);
  // }

  @override
  void dispose() {
    super.dispose();
    // subscription?.cancel();
    event?.cancel();
  }

  // _refresh() {
  //   subscription?.cancel();
  //   _subscribe();
  // }

  _handleError() {}
  _onPostsReceived(DatabaseEvent event) {
    // print(event.toString());
    print(event.snapshot.children.length);

    var items = <PostElement>[];
    for (final child in event.snapshot.children) {
      print(child.value);
      PostElement element = PostElement.fromMap(Map<String, dynamic>.from(child
              .value
          as Map<Object?, Object?>)); //child.value as Map<Object?,Object?>);
      element.uniqueKey = child.key;
      items.add(element);
      print(element.toMap());
    }

    setState(() {
      posts = items;
    });
    // if ((event as List<dynamic>).isNotEmpty) {
    //   setState(() {
    //     _fetching = false;
    //     _errorFetching = false;
    //     post = postFromMap(event)[0];
    //   });
    // }
  }

  _deletePostItem(PostElement item) async {
    ref.child(item.uniqueKey!).remove();
//     List<PostElement> element =
//         post!.posts.where((element) => element.id != item.id).toList();

//     ProgressDialog pd = ProgressDialog(context: context);
//     pd.show(max: 100, msg: 'Deleting post');

// //    post!.posts = element;

//     var response = await supabase
//         .from('posts')
//         .update({
//           'posts': List<dynamic>.from(element.map((x) => x.toMap())),
//         })
//         .eq('id', post!.id)
//         .execute();

//     pd.close();
//     if (response.hasError) {
//       ScaffoldMessenger.of(NavigationService.navigatorKey.currentState!.context)
//           .showSnackBar(SnackBar(content: Text("Error deleting post")));
//       return;
//     }
//     _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kColorDarkGreen,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.add_story);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add post"),
      ),
      body: _fetching
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _errorFetching
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // _refresh();
                      },
                      child: const Text("Error fetching post, Tap to refresh"),
                    ),
                  ),
                )
              : (posts.isEmpty)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            //   _refresh();
                          },
                          child: const Text("You dont have any posts"),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        PostElement item = posts[index];

                        if (item.mediaType == MediaType.text) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StoryViewIndividual(
                                          post: item,
                                          avatarUrl: item.avatarUrl!,
                                          userName: item.userName!)),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.text_fields,
                                    color: kColorDarkGreen,
                                  ),
                                  title: Text(item.caption!),
                                  // subtitle: Text(
                                  //     terms[index].videoNumber.toString() +
                                  //         " Videos"),
                                  trailing: InkWell(
                                    onTap: () {
                                      _deletePostItem(item);
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: kColorDarkGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (item.mediaType == MediaType.image) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StoryViewIndividual(
                                          post: item,
                                          avatarUrl: item.avatarUrl!,
                                          userName: item.userName!)),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.image,
                                    color: kColorDarkGreen,
                                  ),
                                  title: const Text("Image"),
                                  subtitle: Text(item.caption == null
                                      ? ""
                                      : item.caption!),
                                  trailing: InkWell(
                                    onTap: () {
                                      _deletePostItem(item);
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: kColorDarkGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StoryViewIndividual(
                                          post: item,
                                          avatarUrl: item.avatarUrl!,
                                          userName: item.userName!)),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.video_call,
                                    color: kColorDarkGreen,
                                  ),
                                  title: const Text("Video"),
                                  subtitle: Text(item.caption == null
                                      ? ""
                                      : item.caption!),
                                  trailing: InkWell(
                                    onTap: () {
                                      _deletePostItem(item);
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: kColorDarkGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.grey,
                        );
                      },
                      itemCount: posts.length),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Posts'),
  //     ),
  //     floatingActionButton: FloatingActionButton.extended(
  //       backgroundColor: kColorDarkGreen,
  //       onPressed: () {
  //         Navigator.of(context).pushNamed(Routes.add_story);
  //       },
  //       icon: const Icon(Icons.add),
  //       label: const Text("Add post"),
  //     ),
  //     body: _fetching
  //         ? SizedBox(
  //             width: MediaQuery.of(context).size.width,
  //             height: MediaQuery.of(context).size.height,
  //             child: const Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           )
  //         : _errorFetching
  //             ? SizedBox(
  //                 width: MediaQuery.of(context).size.width,
  //                 height: MediaQuery.of(context).size.height,
  //                 child: Center(
  //                   child: InkWell(
  //                     onTap: () {
  //                       // _refresh();
  //                     },
  //                     child: const Text("Error fetching post, Tap to refresh"),
  //                   ),
  //                 ),
  //               )
  //             : (post == null || post!.posts.isEmpty)
  //                 ? SizedBox(
  //                     width: MediaQuery.of(context).size.width,
  //                     height: MediaQuery.of(context).size.height,
  //                     child: Center(
  //                       child: InkWell(
  //                         onTap: () {
  //                           //   _refresh();
  //                         },
  //                         child: const Text("You dont have any posts"),
  //                       ),
  //                     ),
  //                   )
  //                 : ListView.separated(
  //                     itemBuilder: (context, index) {
  //                       PostElement item = post!.posts[index];

  //                       if (item.mediaType == MediaType.text) {
  //                         return Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                               vertical: 0.0, horizontal: 10.0),
  //                           child: InkWell(
  //                             onTap: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => StoryViewIndividual(
  //                                         post: item,
  //                                         avatarUrl: post!.avatarUrl!,
  //                                         userName: post!.username!)),
  //                               );
  //                             },
  //                             child: Card(
  //                               color: Colors.white,
  //                               child: ListTile(
  //                                 leading: Icon(
  //                                   Icons.text_fields,
  //                                   color: kColorDarkGreen,
  //                                 ),
  //                                 title: Text(item.caption!),
  //                                 // subtitle: Text(
  //                                 //     terms[index].videoNumber.toString() +
  //                                 //         " Videos"),
  //                                 trailing: InkWell(
  //                                   onTap: () {
  //                                     _deletePostItem(item);
  //                                   },
  //                                   child: Icon(
  //                                     Icons.delete,
  //                                     color: kColorDarkGreen,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       } else if (item.mediaType == MediaType.image) {
  //                         return Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                               vertical: 0.0, horizontal: 10.0),
  //                           child: InkWell(
  //                             onTap: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => StoryViewIndividual(
  //                                         post: item,
  //                                         avatarUrl: post!.avatarUrl!,
  //                                         userName: post!.username!)),
  //                               );
  //                             },
  //                             child: Card(
  //                               color: Colors.white,
  //                               child: ListTile(
  //                                 leading: Icon(
  //                                   Icons.image,
  //                                   color: kColorDarkGreen,
  //                                 ),
  //                                 title: const Text("Image"),
  //                                 subtitle: Text(item.caption == null
  //                                     ? ""
  //                                     : item.caption!),
  //                                 trailing: InkWell(
  //                                   onTap: () {
  //                                     _deletePostItem(item);
  //                                   },
  //                                   child: Icon(
  //                                     Icons.delete,
  //                                     color: kColorDarkGreen,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       } else {
  //                         return Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                               vertical: 0.0, horizontal: 10.0),
  //                           child: InkWell(
  //                             onTap: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => StoryViewIndividual(
  //                                         post: item,
  //                                         avatarUrl: post!.avatarUrl!,
  //                                         userName: post!.username!)),
  //                               );
  //                             },
  //                             child: Card(
  //                               color: Colors.white,
  //                               child: ListTile(
  //                                 leading: Icon(
  //                                   Icons.video_call,
  //                                   color: kColorDarkGreen,
  //                                 ),
  //                                 title: Text("Video"),
  //                                 subtitle: Text(item.caption == null
  //                                     ? ""
  //                                     : item.caption!),
  //                                 trailing: InkWell(
  //                                   onTap: () {
  //                                     _deletePostItem(item);
  //                                   },
  //                                   child: Icon(
  //                                     Icons.delete,
  //                                     color: kColorDarkGreen,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       }
  //                     },
  //                     separatorBuilder: (context, index) {
  //                       return const Divider(
  //                         color: Colors.grey,
  //                       );
  //                     },
  //                     itemCount: post!.posts.length),
  //   );
  // }
}

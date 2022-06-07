import 'dart:async';
import 'dart:collection';

import 'package:bridgemetherapist/components/story_circle.dart';
import 'package:bridgemetherapist/model/Posts.dart';
import 'package:bridgemetherapist/pages/story_screen/story_view.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StoryOverView extends StatefulWidget {
  StoryOverView({Key? key}) : super(key: key);

  @override
  State<StoryOverView> createState() => _StoryOverViewState();
}

class _StoryOverViewState extends State<StoryOverView> {
  //RealtimeSubscription? subscription;
  //StreamSubscription? sub;

  DatabaseReference ref = FirebaseDatabase.instance.ref("bridgeme/posts");
  StreamSubscription<DatabaseEvent>? event;

  var posts = <Post>[];

  @override
  void initState() {
    super.initState();

    event = ref
        // equalTo(supabase.auth.currentUser!.id,key: "user_id").

        .onValue
        .listen((event) {
      _onPostsReceived(event);
    }, onError: (error) {
      // Error.
    });
  }

  @override
  void dispose() {
    event?.cancel();
    super.dispose();
  }

  // _fetch() async {
  //   subscription = supabase
  //       .from('posts')
  //       .on(SupabaseEventTypes.all, _onPostsReceived)
  //       .subscribe();

  //   sub = supabase
  //       .from("posts")
  //       .stream(['id'])
  //       .order('created_at')
  //       .execute()
  //       .listen(_onPostsReceived);
  // }

  // @override
  // void dispose() {
  //   if (subscription != null) {
  //     supabase.removeSubscription(subscription!);
  //   }
  //   sub?.cancel();
  //   super.dispose();
  // }

  _onPostsReceived(DatabaseEvent items) {
    var _posts = <Post>[];

    Map<Post, List<PostElement>> x = HashMap();

    for (final child in items.snapshot.children) {
      print(child.value);
      PostElement element = PostElement.fromMap(Map<String, dynamic>.from(child
              .value
          as Map<Object?, Object?>)); //child.value as Map<Object?,Object?>);
      element.uniqueKey = child.key;

      Post post = Post(
          id: 0,
          createdAt: DateTime.now(),
          avatarUrl: element.avatarUrl,
          username: element.userName,
          posts: [],
          userId: element.userId!);

      if (x.containsKey(post)) {
        x[post]!.add(element);
      } else {
        x[post] = [element];
      }
      print(element.toMap());
    }

    x.forEach((key, value) {
      key.posts = value;
      _posts.add(key);
    });

    // print(items);
    // List<Post> posts_ = postFromMap(items);
    // print(posts_);
    setState(() {
      posts = _posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        GestureDetector(
          onTap: () {
            //  press();
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.of(context).pushNamed(Routes.posts);
          },
          child: Container(
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 1),
            child: Column(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kColorDarkGreen, kColorDarkGreen],
                    ),
                  ),
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(3.0),
                      child: Image.asset(
                        "assets/images/plus.png",
                        color: kColorDarkGreen,
                      )),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.black, fontSize: 13),
                  ),
                )
              ],
            ),
          ),
        ),
        ...List.generate(
          posts.length,
          (index) {
            return StoryCircle(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryView_(
                        post: posts[index],
                      ),
                    ),
                  );
                  // Get.to(StoryScreen(user: users[index]));
                },
                post: posts[index],
                size: 75,
                tickBorder: 3.0);
          },
        )
      ],
    );
  }
}

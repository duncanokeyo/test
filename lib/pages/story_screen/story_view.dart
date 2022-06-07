import 'package:bridgemetherapist/model/Posts.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryView_ extends StatefulWidget {
  Post post;
  StoryView_({Key? key, required this.post}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StoryViewState(post: post);
  }
}

class _StoryViewState extends State<StoryView_> {
  Post post;

  _StoryViewState({required this.post});

  final StoryController controller = StoryController();

  Widget _buildProfileView(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 24,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10,),
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(post.avatarUrl!),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                post.username,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                post.posts[0].getTimeAgo(),
                style: const TextStyle(
                  color: Colors.white38,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
              onComplete: () {
                Navigator.of(context).pop();
              },
              progressPosition: ProgressPosition.top,
              storyItems: List.generate(
                post.posts.length,
                (index) {
                  PostElement element = post.posts[index];
                  if (element.mediaType == MediaType.text) {
                    return StoryItem.text(
                      title: element.caption!,
                      backgroundColor: Colors.red,
                      textStyle: const TextStyle(
                        fontFamily: 'Dancing',
                        fontSize: 40,
                      ),
                    );
                  } else if (element.mediaType == MediaType.video) {
                    return StoryItem.pageVideo(element.media!,
                        caption: element.caption, controller: controller);
                  } else if (element.mediaType == MediaType.image) {
                    return StoryItem.pageImage(
                        url: element.media!,
                        caption: element.caption,
                        controller: controller);
                  } else {
                    return StoryItem.text(
                      title: "Welcome to BridgeME",
                      backgroundColor: Colors.yellow,
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Dancing',
                        fontSize: 40,
                      ),
                    );
                  }
                },
              ),
              controller: controller),
          Container(
            padding: const EdgeInsets.only(
              top: 48,
              left: 16,
              right: 16,
            ),
            child: _buildProfileView(context),
          )
        ],
      ),
    );
  }
}

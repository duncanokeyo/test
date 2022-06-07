import 'package:bridgemetherapist/model/Posts.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryViewIndividual extends StatefulWidget {
  PostElement post;
  String avatarUrl;
  String userName;
  StoryViewIndividual(
      {Key? key,
      required this.post,
      required this.avatarUrl,
      required this.userName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StoryViewIndividualState(post: post);
  }
}

class StoryViewIndividualState extends State<StoryViewIndividual> {
  PostElement post;

  StoryViewIndividualState({required this.post});

  final StoryController controller = StoryController();

  Widget _buildProfileView(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 24,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(widget.avatarUrl),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.userName,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                post.getTimeAgo(),
                style: TextStyle(
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
              progressPosition: ProgressPosition.top,
              storyItems: [
                if (post.mediaType == MediaType.text) ...[
                  StoryItem.text(
                    title: post.caption!,
                    backgroundColor: Colors.red,
                    textStyle: TextStyle(
                      fontFamily: 'Dancing',
                      fontSize: 40,
                    ),
                  )
                ] else if (post.mediaType == MediaType.video) ...[
                  StoryItem.pageVideo(post.media!,
                      caption: post.caption, controller: controller)
                ] else if (post.mediaType == MediaType.image) ...[
                  StoryItem.pageImage(
                      url: post.media!,
                      caption: post.caption,
                      controller: controller)
                ] else ...[
                  StoryItem.text(
                    title: "Welcome to BridgeME",
                    backgroundColor: Colors.yellow,
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Dancing',
                      fontSize: 40,
                    ),
                  )
                ]
              ],
              controller: controller),
          Container(
            padding: EdgeInsets.only(
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

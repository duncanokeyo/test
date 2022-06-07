import 'package:bridgemetherapist/model/user.dart';
import 'package:meta/meta.dart';

enum MediaType{
	image,
	video
}

class StoryModel {
	final String url;
	final MediaType media;
	final Duration duration;
	final User user;

	StoryModel({
		required this.url,
		required this.media,
		required this.duration,
		required this.user,
	});
}

final List<User> users = [
	User(
		bio:"Ini Bio ku\ndan ini juga bio ku",
		lastName: "Jake",
		hasStory: true,
		firstName: "Jackson",
		profileImage : "https://video.cgtn.com/news/336b444e78517a4e3141444f3249444f78516a4e31457a6333566d54/video/51edaa01e6d14ffc8df031c4cdf3b246/51edaa01e6d14ffc8df031c4cdf3b246.jpg"
	),
	User(
		bio:"Ini Bio ku\n dan ini juga bio ku",
		lastName: "Diane",
		hasStory: true,
		firstName: "Mary",
		profileImage : "https://assets.zencare.co/2020/10/how-to-find-a-black-therapist-1.jpg"
	),
	
];

final List<StoryModel> stories = [
  // StoryModel(
  //   url:
  //       'https://instagram.fcgk9-1.fna.fbcdn.net/v/t51.2885-15/e35/123140665_355030995761254_2310892311522765223_n.jpg?_nc_ht=instagram.fcgk9-1.fna.fbcdn.net&_nc_cat=110&_nc_ohc=ljm24KoobZwAX_BxwD3&tp=1&oh=72f6c0784cbe89d8b830741440f10adb&oe=5FE1E4BB',
  //   media: MediaType.image,
  //   duration: const Duration(seconds: 3),
  //   user: users[0],
  // ),
  // StoryModel(
  //   url:
  //       'http://techslides.com/demos/sample-videos/small.mp4',
  //   media: MediaType.video,
  //   duration: const Duration(seconds: 0),
  //   user: users[0],
  // ),
  StoryModel(
    url:'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTo9uKHVGjTolD5xVn0zezwOxjrnaspeV6eUzZtHU3cwtnhuZb_Pig57_21tiKzKiCT3NE&usqp=CAU',
    media: MediaType.image,
    duration: const Duration(seconds: 5),
    user: users[0],
  ),
  StoryModel(
    url:'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShlLKGn1mrQ3ohMnPRkID4lC0UtT5Gb2Ggbg&usqp=CAU',
    media: MediaType.image,
    duration: const Duration(seconds: 3),
    user: users[0],
  ),
  StoryModel(
    url:'https://www.voicesofyouth.org/sites/voy/files/images/2021-08/1b7f385e-fe6b-4aab-88b3-1966b43dadc3.jpeg',
    media: MediaType.image,
    duration: const Duration(seconds: 3),
    user: users[0],
  ),
  StoryModel(
    url:'https://i.guim.co.uk/img/media/8996e9f65b6114864071929d268eb70f48297f86/0_101_3000_1800/master/3000.jpg?width=1020&quality=85&auto=format&fit=max&s=08202a1f10d6b0dd525b0534b128b90c',
    media: MediaType.image,
    duration: const Duration(seconds: 3),
    user: users[0],
  ),
  StoryModel(
    url: 'https://rm7ix2r8hzo4121x321k81m1-wpengine.netdna-ssl.com/wp-content/uploads/2021/04/May-Is-Mental-Health-Month.jpg',
    media: MediaType.image,
    duration: const Duration(seconds: 3),
    user: users[0],
  ),
  StoryModel(
    url: 'https://cdn130.picsart.com/320383836100201.gif',
    media: MediaType.image,
    user: users[0],
    duration: const Duration(seconds: 3),
  ),




  
];
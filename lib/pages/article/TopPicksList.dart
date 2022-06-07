import 'package:bridgemetherapist/controller/TopPicksController.dart';
import 'package:bridgemetherapist/model/TopPicks.dart';
import 'package:bridgemetherapist/pages/article/article_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopPicksList extends StatelessWidget {
  TopPicksController controller = Get.find<TopPicksController>();

  // TopPicksList({
  //   Key? key,
  // }) {
  //   controller.fetch(false);
  // }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.isTrue) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (controller.isLoading.isFalse && controller.error.isNotEmpty) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: InkWell(
            onTap: () {
              controller.fetch(true);
            },
            child: const Center(
              child: Text("Error fetching top picks tap to refresh"),
            ),
          ),
        );
      } else if (controller.isLoading.isFalse &&
          controller.error.isEmpty &&
          controller.results.isEmpty) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: InkWell(
            onTap: () {
              controller.fetch(true);
            },
            child: const Center(
              child: Text("No top picks"),
            ),
          ),
        );
      } else {
        return Column(
          children: List.generate(controller.results.length, (index) {
            TopPicks pick = controller.results[index];
            return getCard(context, pick);
          }),
        );
      }
    });
  }
}

Widget getCard(BuildContext context, TopPicks picks) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ArticleDetailsWidget(
                  bannerUrl: picks.getBannerUrl(),
                  title: picks.title,
                  avatarUrl: picks.avatarUrl,
                  date: picks.date,
                  gender: "Male",
                  content: picks.content,
                  description: picks.description,
                  category: picks.category,
                  userName: picks.username)),
        );
      },
      child: ListTile(
        visualDensity: const VisualDensity(vertical: 1), // to expand

        isThreeLine: true,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: CachedNetworkImage(
            imageUrl: picks.getBannerUrl(),
            fit: BoxFit.cover,
            height: 100,
            width: 90,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              picks.category,
              style: const TextStyle(
                  color: Color(0xff2e66e7),
                  fontFamily: "Product_Sans_Regular",
                  fontSize: 10.0,
                  height: 1.4),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 150,
              child: Text(
                picks.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: "Product_Sans_Bold"),
                maxLines: 2,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              picks.username,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                  color: Color(0xff9b9b9b),
                  fontSize: 12.0,
                  fontFamily: "Product_Sans_Regular"),
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),

      // child: Row(
      //   children: <Widget>[
      //     ClipRRect(
      //       borderRadius: BorderRadius.circular(12.0),
      //       child: CachedNetworkImage(
      //         imageUrl: picks.getBannerUrl(),
      //         fit: BoxFit.cover,
      //         height: 90,
      //         width: 90,
      //       ),
      //     ),
      //     SizedBox(
      //       width: 10,
      //     ),
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       children: <Widget>[
      //         Text(
      //           picks.category,
      //           style: TextStyle(
      //               color: Color(0xff2e66e7),
      //               fontFamily: "Product_Sans_Regular",
      //               fontSize: 10.0,
      //               height: 1.4),
      //         ),
      //         SizedBox(
      //           height: 4,
      //         ),
      //         Container(
      //           width: MediaQuery.of(context).size.width - 150,
      //           child: Text(
      //             picks.title,
      //             overflow: TextOverflow.ellipsis,
      //             style: TextStyle(
      //                 color: Colors.black,
      //                 fontSize: 18.0,
      //                 fontFamily: "Product_Sans_Bold"),
      //             maxLines: 2,
      //           ),
      //         ),
      //         SizedBox(
      //           height: 4,
      //         ),
      //         Text(
      //           picks.username,
      //           overflow: TextOverflow.clip,
      //           textAlign: TextAlign.justify,
      //           style: TextStyle(
      //               color: Color(0xff9b9b9b),
      //               fontSize: 12.0,
      //               fontFamily: "Product_Sans_Regular"),
      //         )
      //       ],
      //     )
      //   ],
      // ),
    ),
  );
}

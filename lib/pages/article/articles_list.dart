import 'package:bridgemetherapist/model/Articles.dart';
import 'package:bridgemetherapist/pages/article/article_detail.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controller/ArticlesController.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ArticlesList extends StatelessWidget {
  ArticlesController controller = Get.find<ArticlesController>();

  // ArticlesList({
  //   Key? key,
  // }) {
  //   controller.fetch(false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: Obx(
        () {
          if (controller.isLoading.isTrue) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isNotEmpty) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InkWell(
                onTap: () {
                  controller.fetch(true);
                },
                child: Center(
                  child: const Text("Error fetching articles tap to refresh"),
                ),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isEmpty &&
              controller.results.isEmpty) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InkWell(
                onTap: () {
                  controller.fetch(true);
                },
                child: Center(
                  child: const Text("No articles"),
                ),
              ),
            );
          } else {
            return SmartRefresher(
              controller: controller.refreshController,
              enablePullDown: true,
              enablePullUp: false,
              onRefresh: () {
                controller.fetch(true);
                controller.refreshController.refreshCompleted();
              },
              child: Padding(
                padding: kIsWeb
                    ? EdgeInsets.only(left: WEBPADDING, right: WEBPADDING, top: 20)
                    : const EdgeInsets.only(top: 5),
                child: SingleChildScrollView(
                    child: Column(
                  children: List.generate(controller.results.length, (index) {
                    Articles pick = controller.results[index];
                    return getCard(context, pick);
                  }),
                )),
              ),
            );
          }
        },
      ),
    );
  }

  Widget getCard(BuildContext context, Articles article) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ArticleDetailsWidget(
                    bannerUrl: article.getBannerUrl(),
                    title: article.title,
                    avatarUrl: article.avatarUrl,
                    date: article.date,
                    content: article.content,
                    gender: "Male",
                    description: article.description,
                    category: article.category,
                    userName: article.username)),
          );
        },
        child: ListTile(
          visualDensity: const VisualDensity(vertical: 1), // to expand

          isThreeLine: true,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: CachedNetworkImage(
              imageUrl: article.getBannerUrl(),
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
                article.category,
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
                  article.title,
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
                article.username,
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
      ),
    );
  }
}

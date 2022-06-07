import 'package:bridgemetherapist/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


// class ArticleDetailsWidget extends StatefulWidget {
//   String bannerUrl;
//   String title;
//   String avatarUrl;
//   DateTime date;
//   String content;
//   String description;
//   String gender;
//   String category;
//   String userName;
//   ArticleDetailsWidget(
//       {required this.bannerUrl,
//       required this.title,
//       required this.avatarUrl,
//       required this.gender,
//       required this.date,
//       required this.content,
//       required this.description,
//       required this.category,
//       required this.userName});

//   @override
//   _ArticleDetailsWidgetState createState() => _ArticleDetailsWidgetState();
// }

// class _ArticleDetailsWidgetState extends State<ArticleDetailsWidget> {
//   getImageAsset() {
//     if (widget.gender == "Male") {
//       return "assets/images/icon_doctor_5.png";
//     }
//     return "assets/images/icon_doctor_4.png";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''),
//       ),
//       body: Stack(
//         fit: StackFit.passthrough,
//         alignment: Alignment.topLeft,
//         children: <Widget>[
//           CachedNetworkImage(
//             imageUrl: widget.bannerUrl,
//             height: 280,
//             width: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 32.0, left: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 // InkWell(
//                 //   onTap: () {
//                 //     Navigator.pop(context);
//                 //   },
//                 //   child: Container(
//                 //     height: 48,
//                 //     width: 48,
//                 //     decoration: BoxDecoration(
//                 //         borderRadius: BorderRadius.all(Radius.circular(24.0)),
//                 //         boxShadow: [
//                 //           BoxShadow(
//                 //             color: Colors.black12,
//                 //             blurRadius:
//                 //                 20.0, // has the effect of softening the shadow
//                 //             spreadRadius: 2.0,
//                 //             offset: Offset(
//                 //               5.0, // horizontal, move right 10
//                 //               5.0, // vertical, move down 10
//                 //             ),
//                 //           ),
//                 //         ],
//                 //         color: Colors.black45),
//                 //     child: IconButton(
//                 //       onPressed: () {},
//                 //       icon: Icon(
//                 //         Icons.arrow_back,
//                 //         color: Colors.white,
//                 //         size: 24.0,
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),

//                 SizedBox(
//                   height: 62,
//                 ),
//                 Container(
//                   height: 24,
//                   width: 72,
//                   decoration: BoxDecoration(
//                       color: Color(0xFFffffffff),
//                       borderRadius: BorderRadius.circular(20.0)),
//                   child: Center(
//                     child: Text(
//                       widget.category,
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontFamily: "Product_Sans_Regular",
//                           fontSize: 12.0,
//                           height: 1.4),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     widget.description,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 32.0,
//                         fontFamily: "Product_Sans_Bold"),
//                   ),
//                 )
//               ],
//             ),
//           ),

//           SingleChildScrollView(
//             child: Container(
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(16.0),
//                         topLeft: Radius.circular(16.0)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 16.0,
//                       ),
//                     ],
//                     color: Color(0xfffafafa)),
//                 margin: EdgeInsets.only(top: 266),
//                 child: Column(
//                   children: <Widget>[
//                     SizedBox(
//                       height: 24,
//                     ),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         SizedBox(
//                           width: 16.0,
//                         ),
//                         ClipOval(
//                           child: CachedNetworkImage(
//                             width: 40,
//                             height: 40,
//                             imageBuilder: (context, imageProvider) =>
//                                 CircleAvatar(
//                               radius: 30,
//                               backgroundImage: imageProvider,
//                             ),
//                             imageUrl: widget.avatarUrl,
//                             errorWidget: (contex, url, error) {
//                               return CircleAvatar(
//                                 radius: 30,
//                                 backgroundColor: Colors.transparent,
//                                 child: Image.asset(
//                                   getImageAsset(),
//                                   fit: BoxFit.fill,
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         // ClipOval(
//                         //   child: CachedNetworkImage(
//                         //     imageUrl: widget.avatarUrl,
//                         //     height: 42,
//                         //     width: 42,
//                         //     fit: BoxFit.cover,
//                         //   ),
//                         // ),
//                         SizedBox(
//                           width: 12.0,
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 2.0, horizontal: 0.0),
//                               child: Text(
//                                 widget.userName,
//                                 style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16.0,
//                                     fontFamily: "Product_Sans_Regular"),
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 0.0, horizontal: 0.0),
//                               child: Text(
//                                 widget.date.toString(),
//                                 style: TextStyle(
//                                     color: Color(0xff9b9b9b),
//                                     fontSize: 12.0,
//                                     fontFamily: "Product_Sans_Regular"),
//                               ),
//                             )
//                           ],
//                         )
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8.0, horizontal: 16.0),
//                       child: Text(
//                         widget.content,
//                         style: TextStyle(
//                             height: 1.4,
//                             color: Color(0xff464646),
//                             fontSize: 18.0,
//                             fontFamily: "Product_Sans_Regular"),
//                       ),
//                     )
//                   ],
//                 )),
//           ),

//           // Align(
//           //   alignment: Alignment.topRight,
//           //   child: Padding(
//           //     padding: const EdgeInsets.only(top: 242, right: 32),
//           //     child: Container(
//           //       height: 48,
//           //       width: 48,
//           //       decoration: BoxDecoration(
//           //           borderRadius: BorderRadius.all(Radius.circular(24.0)),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black12,
//           //               blurRadius:
//           //                   20.0, // has the effect of softening the shadow
//           //               spreadRadius: 2.0,
//           //               offset: Offset(
//           //                 5.0, // horizontal, move right 10
//           //                 5.0, // vertical, move down 10
//           //               ),
//           //             ),
//           //           ],
//           //           color: Colors.white),
//           //       child: IconButton(
//           //         onPressed: () {},
//           //         icon: Icon(
//           //           Icons.bookmark_border,
//           //           color: Colors.black,
//           //           size: 24.0,
//           //         ),
//           //       ),
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

class ArticleDetailsWidget extends StatefulWidget {
  String bannerUrl;
  String title;
  String avatarUrl;
  DateTime date;
  String content;
  String description;
  String gender;
  String category;
  String userName;
  ArticleDetailsWidget(
      {required this.bannerUrl,
      required this.title,
      required this.avatarUrl,
      required this.gender,
      required this.date,
      required this.content,
      required this.description,
      required this.category,
      required this.userName});

  @override
  _ArticleDetailsWidgetState createState() => _ArticleDetailsWidgetState();
}

class _ArticleDetailsWidgetState extends State<ArticleDetailsWidget> {
  getImageAsset() {
    if (widget.gender == "Male") {
      return "assets/images/icon_doctor_5.png";
    }
    return "assets/images/icon_doctor_4.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              //backgroundColor: Colors.white,
              elevation: 1,
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.bannerUrl,

                  errorWidget: (contex, url, error) {
                    return Container();
                  },
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: kIsWeb?const EdgeInsets.only(left: 150,right: 150,top: 20,bottom: 20) :const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 16.0,
                    ),
                    ClipOval(
                      child: CachedNetworkImage(
                        width: 40,
                        height: 40,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 30,
                          backgroundImage: imageProvider,
                        ),
                        imageUrl: widget.avatarUrl,
                        errorWidget: (contex, url, error) {
                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              getImageAsset(),
                              fit: BoxFit.fill,
                            ),
                          );
                        },
                      ),
                    ),
                    // ClipOval(
                    //   child: CachedNetworkImage(
                    //     imageUrl: widget.avatarUrl,
                    //     height: 42,
                    //     width: 42,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    const SizedBox(
                      width: 12.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 0.0),
                          child: Text(
                            widget.userName,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontFamily: "Product_Sans_Regular"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 0.0),
                          child: Text(
                            Utils.humanReadableDate(widget.date),
                            style: const TextStyle(
                                color: const Color(0xff9b9b9b),
                                fontSize: 12.0,
                                fontFamily: "Product_Sans_Regular"),
                          ),
                        )
                      ],
                    )
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
                // Divider(
                //   height: 1,
                //   color: Colors.grey[350],
                // ),
                // SizedBox(
                //   height: 20,
                // ),
                //  Row(
                //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //    children: <Widget>[
                //      CustomCircularIndicator(
                //        radius: 80,
                //        percent: 0.85,
                //        lineWidth: 5,
                //        line1Width: 2,
                //        footer: 'good_reviews'.tr(),
                //      ),
                //      SizedBox(
                //        width: 10,
                //      ),
                //      CustomCircularIndicator(
                //        radius: 80,
                //        percent: 0.95,
                //       lineWidth: 5,
                //        line1Width: 2,
                //        footer: 'total_score'.tr(),
                //      ),
                //      SizedBox(
                //        width: 10,
                //      ),
                //      CustomCircularIndicator(
                //        radius: 80,
                //        percent: 0.9,
                //        lineWidth: 5,
                //        line1Width: 2,
                //        footer: 'satisfaction'.tr(),
                //      ),
                //    ],
                //  ),
                //  SizedBox(
                //    height: 20,
                //  ),
                //  Divider(
                //    height: 1,
                //    color: Colors.grey[350],
                //  ),
                //  SizedBox(
                //   height: 20,
                //  ),
               
                Text(
                  widget.content,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: kIsWeb?20: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    // RoundIconButton(
                    //   onPressed: () {},
                    //   icon: Icons.message,
                    //   elevation: 1,
                    // ),
                    // SizedBox(
                    //   width: 10,
                    // ),
                    // RoundIconButton(
                    //   onPressed: () {},
                    //   icon: Icons.phone,
                    //   elevation: 1,
                    // ),
                    
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

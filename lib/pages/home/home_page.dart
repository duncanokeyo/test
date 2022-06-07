import 'package:bridgemetherapist/controller/ArticlesController.dart';
import 'package:bridgemetherapist/controller/CompletedSessions.dart';
import 'package:bridgemetherapist/controller/PatientsSeenController.dart';
import 'package:bridgemetherapist/controller/TopPicksController.dart';
import 'package:bridgemetherapist/controller/UpcomingSessionsController.dart';
import 'package:bridgemetherapist/pages/article/TopPicksList.dart';
import 'package:bridgemetherapist/pages/story_screen/story_overview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../routes/routes.dart';
import 'widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: () {
        _refreshController.refreshCompleted();
        Get.find<TopPicksController>().fetch(true);
        Get.find<ArticlesController>().fetch(true);
        Get.find<UpcomingSessionsController>().fetch(true);
        Get.find<CompletedSessionsController>().fetch(true);
        Get.find<PatientsSeenController>().fetch(true);
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: kIsWeb?const EdgeInsets.only(left: 0,right: 0):const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              kIsWeb?Container():Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(width: 1, color: Colors.grey[300]!!),
                          ),
                        ),
                        height: 120,
                        child: StoryOverView(),
                      ),
                    )
                  ],
                ),
                // child: Row(
                //   children: <Widget>[
                //     Image.asset('assets/images/hand.png'),
                //     SizedBox(
                //       width: 10,
                //     ),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: <Widget>[
                //         Text(
                //           '${'hello'.tr()} Faith,',
                //           style: Theme.of(context).textTheme.headline6!.copyWith(
                //                 fontWeight: FontWeight.w400,
                //               ),
                //         ),
                //         Text(
                //           'how_are_you_today'.tr(),
                //           style: TextStyle(
                //             color: Colors.grey,
                //             fontSize: 14,
                //             fontFamily: 'NunitoSans',
                //             fontWeight: FontWeight.w400,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: <Widget>[
                        NextAppointmentWidget(),
                   //     PatientsSeenOverview(),
                      ],
                    ),
                  ),

                  // Container(
                  //   height: 160,
                  //   child: ListView.separated(
                  //     separatorBuilder: (context, index) => SizedBox(
                  //       width: 15,
                  //     ),
                  //     itemCount: 4,
                  //     scrollDirection: Axis.horizontal,
                  //     padding: EdgeInsets.symmetric(horizontal: 20),
                  //     itemBuilder: (context, index) {
                  //       return VisitedDoctorListItem(
                  //         doctor: doctors[index],
                  //       );
                  //     },
                  //   ),
                  // ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SectionHeaderWidget(
                          title: 'top_picks'.tr(),
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.articles);
                          },
                        ),

                        TopPicksList()
                        //test results
                      ],
                    ),
                  ),
                ],
              ),
              // _noAppoints
              //     ? NoAppointmentsWidget()
              //     :
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

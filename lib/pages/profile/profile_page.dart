import 'package:bridgemetherapist/model/Profile.dart';
import 'package:bridgemetherapist/pages/appointment/history_appointments_page.dart';
import 'package:bridgemetherapist/pages/appointment/upcoming_appointments_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';

import '../../components/round_icon_button.dart';
import '../../data/pref_manager.dart';
import '../../routes/routes.dart';
import '../../utils/constants.dart';
import '../examination/examination_page.dart';
import '../prescription/prescription_page.dart';
import '../test/test_page.dart';

import '../visit/visit_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  final box = Get.find<GetStorage>();
  late Profile profile;
  _ProfilePageState() {
  }
  final _kTabTextStyle = TextStyle(
    color: kColorGreen,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
  );

  final _kTabPages = [
    //VisitPage(),
    UpcomingAppointmentsPage(),
    HistoryAppointmentsPage(),
    //ExaminationPage(),
    //TestPage(),
    //PrescriptionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
        profile = profileFromMap(box.read('profile'))[0];

    bool _isdark = Prefs.isDark();

    var _kTabs = [
      Tab(
        text: 'upcoming'.tr(),
      ),
      Tab(
        text: 'history'.tr(),
      ),
      // Tab(
      //   text: 'visit'.tr(),
      // ),
      // Tab(
      //   text: 'examination'.tr(),
      // ),
      // Tab(
      //   text: 'test'.tr(),
      // ),
      // Tab(
      //   text: 'prescription'.tr(),
      // ),
    ];

    return Column(
      children: <Widget>[
        // Container(
        //   padding: EdgeInsets.all(20),
        //   //color: Colors.white,
        //   child: Row(
        //     children: <Widget>[
        //       CachedNetworkImage(
        //         imageBuilder: (context, imageProvider) => CircleAvatar(
        //           radius: 32,
        //           backgroundImage: imageProvider,
        //         ),
        //         imageUrl: profile.avatarUrl,
        //         errorWidget: (contex, url, error) {
        //           return CircleAvatar(
        //             radius: 32,
        //             backgroundColor: Colors.transparent,
        //             child: Image.asset(
        //               'assets/images/icon_man.png',
        //               fit: BoxFit.fill,
        //             ),
        //           );
        //         },
        //       ),
        //       SizedBox(
        //         width: 20,
        //       ),
        //       Expanded(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: <Widget>[
        //             Text(
        //               profile.username,
        //               style: Theme.of(context).textTheme.subtitle2,
        //             ),
        //             SizedBox(
        //               height: 3,
        //             ),
        //             Text(
        //               profile.email,
        //               style: TextStyle(
        //                 color: Colors.grey[350],
        //                 fontSize: 12,
        //               ),
        //             ),
        //             SizedBox(
        //               height: 5,
        //             ),
        //             Text(
        //               profile.phoneNumber,
        //               style: Theme.of(context)
        //                   .textTheme
        //                   .subtitle2!
        //                   .copyWith(fontSize: 12),
        //             ),
        //           ],
        //         ),
        //       ),
        //       RoundIconButton(
        //         onPressed: () =>
        //             Navigator.of(context).pushNamed(Routes.editProfile),
        //         icon: Icons.edit,
        //         size: 40,
        //         color: kColorGreen,
        //         iconColor: Colors.white,
        //       ),
        //     ],
        //   ),
        // ),
        // SizedBox(
        //   height: 15,
        // ),


        Expanded(
          child: DefaultTabController(
            length: _kTabs.length,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isdark ? kColorDark : Color(0xfffbfcff),
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: _isdark ? Colors.black87 : Colors.grey[200]!,
                      ),
                      bottom: BorderSide(
                        width: 1,
                        color: _isdark ? Colors.black87 : Colors.grey[200]!,
                      ),
                    ),
                  ),
                  child: TabBar(
                    indicatorColor: kColorGreen,
                    labelStyle: _kTabTextStyle,
                    unselectedLabelStyle:
                        _kTabTextStyle.copyWith(color: Colors.grey),
                    labelColor: kColorGreen,
                    unselectedLabelColor: Colors.grey,
                    tabs: _kTabs,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: _kTabPages,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

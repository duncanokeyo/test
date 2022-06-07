import 'package:bridgemetherapist/components/CircularProfileImage.dart';
import 'package:bridgemetherapist/model/Profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../routes/routes.dart';
import '../../utils/constants.dart';

class DrawerPage extends StatelessWidget {
  final void Function() onTap;
  final box = Get.find<GetStorage>();
  late Profile profile;

  DrawerPage({Key? key, required this.onTap}) {
    profile = profileFromMap(box.read('profile'))[0];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Scaffold(
        backgroundColor: kColorDarkGreen,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 35,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircularProfileImage(
                          avatarUrl: profile.avatarUrl,
                          size: 50,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              profile.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            // Text(
                            //   'O+',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w700,
                            //   ),
                            // ),
                          ],
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(
                    height: 30,
                  ),
                  // _drawerItem(
                  //   image: 'person',
                  //   icon: Icon(
                  //     Icons.person,
                  //     color: Colors.white,
                  //   ),
                  //   text: 'my_doctors',
                  //   onTap: () =>
                  //       Navigator.of(context).pushNamed(Routes.myPatients),
                  // ),
                  _drawerItem(
                    image: 'profile',
                    text: 'Profile',
                    icon: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.editProfile),
                  ),
            
                  _drawerItem(
                    image: 'calendar',
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                    ),
                    text: 'my_appointments',
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.myAppointments),
                  ),
                  _drawerItem(
                    image: 'journal',
                    icon: const Icon(
                      Icons.border_color,
                      color: Colors.white,
                    ),
                    text: 'my_journals',
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.myJournals),
                  ),
                  _drawerItem(
                    image: 'journals',
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    text: 'settings',
                    onTap: () => Navigator.of(context).pushNamed(Routes.settings),
                  ),
                  _drawerItem(
                    image: 'journals',
                    icon: const Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    text: 'sign_out',
                    onTap: () async {
                      var box = Get.find<GetStorage>();
            
                      ProgressDialog pd = ProgressDialog(context: context);
                      pd.show(max: 100, msg: 'Signing out');
                      try {
                        supabase.removeAllSubscriptions();
                        var box = Get.find<GetStorage>();
                        await box.erase();
                      } catch (e) {}
            
                      supabase.auth.signOut().then(
                        (value) {
                          pd.close();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.login, (route) => false);
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InkWell _drawerItem({
    required String image,
    required String text,
    required Icon icon,
    required Function onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        //this.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 58,
        child: Row(
          children: <Widget>[
            icon,
            // SizedBox(
            //   width: 40,
            //   height: 40,
            //   child: Image.asset(
            //     'assets/images/$image.png',
            //     color: Colors.white,
            //   ),
            // ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}

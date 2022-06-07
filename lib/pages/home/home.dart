import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/components/CircularProfileImage.dart';
import 'package:bridgemetherapist/controller/ArticlesController.dart';
import 'package:bridgemetherapist/controller/CompletedSessions.dart';
import 'package:bridgemetherapist/controller/PresetsController.dart';
import 'package:bridgemetherapist/controller/TopPicksController.dart';
import 'package:bridgemetherapist/controller/UpcomingSessionsController.dart';
import 'package:bridgemetherapist/model/Profile.dart';
import 'package:bridgemetherapist/pages/appointment/my_appointments_page.dart';
import 'package:bridgemetherapist/pages/availability/SessionsList.dart';
import 'package:bridgemetherapist/pages/chatroom/chat_room_page.dart';
import 'package:bridgemetherapist/pages/journals/Journal.dart';
import 'package:bridgemetherapist/pages/profile/edit_profile_page.dart';
import 'package:bridgemetherapist/pages/settings/settings_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_scaffold_nullsafe/responsive_scaffold.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes/routes.dart';
import '../../utils/constants.dart';
import '../drawer/drawer_page.dart';
import '../messages/messages_page.dart';
import '../profile/profile_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_page.dart';
import 'widgets/widgets.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PresetsController controller = Get.find<PresetsController>();
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  int _selectedIndex = 0;

  late PageController _pageController;

  RealtimeSubscription? articleSubscription;
  RealtimeSubscription? sessionBookingSubscription;
  RealtimeSubscription? sessionPaymentSubscription;

  @override
  void initState() {
    if (!kIsWeb) {
      FirebaseMessaging.instance
          .subscribeToTopic(supabase.auth.currentUser!.id);

      if (NavigationService.navigatorKey.currentState != null) {
        FirebaseMessaging.onMessage.listen(
          (event) {
            RemoteNotification? notification = event.notification;
            if (notification != null && event.data.isNotEmpty) {
              if (event.data.containsKey('type')) {
              } else {
                showDialog(
                    context:
                        NavigationService.navigatorKey.currentState!.context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(notification.title!),
                        content: Text(notification.body!),
                        actions: [
                          TextButton(
                            child: const Text("Ok"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
              }
            }

            // print("message received");
            // print(notification?.toString());
            // print(notification?.title.toString());
            // print(notification?.body.toString());
            // print(event.data);
          },
        );
      }
    }
    _pageController = PageController(
      initialPage: _selectedIndex,
    );

    if (!controller.isPresetsLoaded()) {
      controller.fetch(true, true, true);
    }

    articleSubscription =
        supabase.from('articles').on(SupabaseEventTypes.all, (payload) {
      // print('-----------payload---articles-------> $payload');
      Get.find<ArticlesController>().fetch(true);
      Get.find<TopPicksController>().fetch(true);
    }).subscribe();

    sessionBookingSubscription = supabase
        .from(
            "session_bookings:therapist_id=eq.${supabase.auth.currentUser!.id}")
        .on(SupabaseEventTypes.all, (payload) {
      // print('-----------payload---session bookings-------> $payload');
      Get.find<UpcomingSessionsController>().fetch(true);
      Get.find<CompletedSessionsController>().fetch(true);
    }).subscribe();

    sessionPaymentSubscription =
        supabase.from('session_payments').on(SupabaseEventTypes.all, (payload) {
      // print('----------payload--session payments ------>$payload');
      Get.find<UpcomingSessionsController>().fetch(true);

      Get.find<CompletedSessionsController>().fetch(true);
    }).subscribe();

    Get.find<ArticlesController>().fetch(true);
    Get.find<TopPicksController>().fetch(true);
    Get.find<UpcomingSessionsController>().fetch(true);
    Get.find<CompletedSessionsController>().fetch(true);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();

    supabase.removeAllSubscriptions();

    // if (articleSubscription != null) {
    //   supabase.removeSubscription(articleSubscription!);
    // }
    // if (sessionBookingSubscription != null) {
    //   supabase.removeSubscription(sessionBookingSubscription!);
    // }
    // if(sessionPaymentSubscription!=null){
    //   supabase.re
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() {
      if (controller.isLoading.isTrue) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (controller.isLoading.isFalse && controller.error.isNotEmpty) {
        return Scaffold(
          body: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: InkWell(
                onTap: () {
                  controller.fetch(true, true, true);
                },
                child: const Text("Error fetching presets. Tap to retry"),
              ),
            ),
          ),
        );
      } else {
        final box = Get.find<GetStorage>();
        Profile profile = profileFromMap(box.read('profile'))[0];

        if (kIsWeb) {
          var _pages = [
            HomePage(),
            ProfilePage(),
            MessagesPage(),
            ChatRoomPage(),
            MyAppointmentsPage(),
            SessionsList(),
            Journal(),
            EditProfilePage(),
            SettingsPage(),
          ];

          return ResponsiveScaffold(
            kDesktopBreakpoint: 1000,
            appBar: AppBar(
              title: AppBarTitleWidget(),
            ),
            drawer: Container(
              color: kColorDarkGreen,
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
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
                  const Divider(
                    height: 1,
                    thickness: 1,
                  ),

                  //  setState(() {
                  //         _selectedIndex = position;
                  //         _pageController.jumpToPage(position);
                  //       });

                  ListTile(
                      leading: Icon(
                        Icons.home,
                        color: _selectedIndex == 0
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                      title: Text(
                        'Home',
                        style: TextStyle(
                          color: _selectedIndex == 0
                              ? Colors.green[100]
                              : Colors.white,
                        ),
                      ),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        _selectedIndex = 0;
                        _pageController.jumpToPage(0);
                      }),
                  ListTile(
                    leading: Icon(
                      Icons.book,
                      color: _selectedIndex == 1
                          ? Colors.green[100]
                          : Colors.white,
                    ),
                    title: Text(
                      'Booked sessions',
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                    ),
                    selected: _selectedIndex == 1,
                    onTap: () {
                      _selectedIndex = 1;
                      _pageController.jumpToPage(1);
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/chat.png',
                      height: 20,
                      color: _selectedIndex == 2
                          ? Colors.green[100]
                          : Colors.white,
                    ),
                    title: Text(
                      'Chat',
                      style: TextStyle(
                        color: _selectedIndex == 2
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                    ),
                    selected: _selectedIndex == 2,
                    onTap: () {
                      _selectedIndex = 2;
                      _pageController.jumpToPage(2);
                    },
                  ),
                  ListTile(
                      leading: Image.asset(
                        'assets/images/community.png',
                        height: 20,
                        color: _selectedIndex == 3
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                      title: Text(
                        'Group chat',
                        style: TextStyle(
                          color: _selectedIndex == 3
                              ? Colors.green[100]
                              : Colors.white,
                        ),
                      ),
                      selected: _selectedIndex == 3,
                      onTap: () {
                        _selectedIndex = 3;
                        _pageController.jumpToPage(3);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.calendar_month,
                        color: _selectedIndex == 4
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                      title: Text(
                        'My appointments',
                        style: TextStyle(
                          color: _selectedIndex == 4
                              ? Colors.green[100]
                              : Colors.white,
                        ),
                      ),
                      selected: _selectedIndex == 4,
                      onTap: () {
                        _selectedIndex = 4;
                        _pageController.jumpToPage(4);
                      }),
                  ListTile(
                    leading: Icon(
                      Icons.bookmark,
                      color: _selectedIndex == 5
                          ? Colors.green[100]
                          : Colors.white,
                    ),
                    title: Text(
                      'Add sessions',
                      style: TextStyle(
                        color: _selectedIndex == 5
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                    ),
                    selected: _selectedIndex == 5,
                    onTap: () {
                      _selectedIndex = 5;
                      _pageController.jumpToPage(5);
                    },
                  ),
                  ListTile(
                      leading: Icon(
                        Icons.border_color,
                        color: _selectedIndex == 6
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                      title: Text(
                        'My journals',
                        style: TextStyle(
                          color: _selectedIndex == 6
                              ? Colors.green[100]
                              : Colors.white,
                        ),
                      ),
                      selected: _selectedIndex == 6,
                      onTap: () {
                        _selectedIndex = 6;
                        _pageController.jumpToPage(6);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.person,
                        color: _selectedIndex == 7
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                      title: Text(
                        'Profile',
                        style: TextStyle(
                          color: _selectedIndex == 7
                              ? Colors.green[100]
                              : Colors.white,
                        ),
                      ),
                      selected: _selectedIndex == 7,
                      onTap: () {
                        _selectedIndex = 7;
                        _pageController.jumpToPage(7);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: _selectedIndex == 8
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                      title: Text(
                        'Settings',
                        style: TextStyle(
                          color: _selectedIndex == 8
                              ? Colors.green[100]
                              : Colors.white,
                        ),
                      ),
                      selected: _selectedIndex == 8,
                      onTap: () {
                        _selectedIndex = 8;
                        _pageController.jumpToPage(8);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: _selectedIndex == 9
                            ? Colors.green[100]
                            : Colors.white,
                      ),
                      title: Text(
                        'Signout',
                        style: TextStyle(
                          color: _selectedIndex == 9
                              ? Colors.green[100]
                              : Colors.white,
                        ),
                      ),
                      selected: _selectedIndex == 9,
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
                      }),
                ],
              ),
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: _pages,
            ),
          );
        } else {
          var _pages = [
            HomePage(),
            ProfilePage(),
            Container(),
            MessagesPage(),
            ChatRoomPage(),
            //  SettingsPage(),
          ];

          return Stack(
            children: <Widget>[
              DrawerPage(
                onTap: () {
                  setState(
                    () {
                      xOffset = 0;
                      yOffset = 0;
                      scaleFactor = 1;
                      isDrawerOpen = false;
                    },
                  );
                },
              ),
              AnimatedContainer(
                transform: Matrix4.translationValues(xOffset, yOffset, 0)
                  ..scale(scaleFactor)
                  ..rotateY(isDrawerOpen ? -0.5 : 0),
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
                  child: Scaffold(
                    appBar: AppBar(
                      leading: isDrawerOpen
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                setState(
                                  () {
                                    xOffset = 0;
                                    yOffset = 0;
                                    scaleFactor = 1;
                                    isDrawerOpen = false;
                                  },
                                );
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                setState(() {
                                  xOffset = size.width - size.width / 3;
                                  yOffset = size.height * 0.1;
                                  scaleFactor = 0.8;
                                  isDrawerOpen = true;
                                });
                              },
                            ),
                      title: AppBarTitleWidget(),
                      actions: <Widget>[
                        if (_selectedIndex == 2) ...[
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.add,
                            ),
                          )
                        ] else if (_selectedIndex == 1) ...[
                          Container(
                            width: 0,
                          ),
                          // IconButton(
                          //   onPressed: () =>
                          //       Navigator.pushNamed(context, Routes.settings),
                          //   icon: const Icon(Icons.settings),
                          // ),
                        ] else if (_selectedIndex == 4) ...[
                          IconButton(
                            onPressed: () => Navigator.pushNamed(
                                context, Routes.add_discussion),
                            icon: const Icon(
                              Icons.border_color_outlined,
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: 0,
                          ),
                          // IconButton(
                          //   onPressed: () => Navigator.pushNamed(
                          //       context, Routes.notifications),
                          //   icon: const Icon(
                          //     Icons.notifications_none,
                          //   ),
                          // ),
                        ]
                      ],
                    ),
                    body: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      children: _pages as List<Widget>,
                    ),
                    floatingActionButton: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x202e83f8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.of(context).pushNamed(Routes.sessions);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kColorGreen,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/calendar-with-check-mark.png',
                                height: 25,
                                width: 25,
                                fit: BoxFit.fill,
                                color: Colors.white,
                              ),
                            ),
                            // Icon(
                            //   Icons.add,
                            //   color: Colors.white,
                            // ),
                          ),
                        ),
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                    bottomNavigationBar: BottomNavigationBar(
                      backgroundColor: Colors.white, // <-- This works for fixed
                      selectedItemColor: kColorDarkGreen,
                      unselectedItemColor: Colors.grey,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      items: [
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.book),
                          label: 'Sessions',
                        ),

                        // NavBarItemWidget(
                        //   onTap: () {
                        //     _selectPage(0);
                        //   },
                        //   image: 'icon_home',
                        //   isSelected: _selectedIndex == 0,
                        // ),
                        // NavBarItemWidget(
                        //   onTap: () {
                        //     _selectPage(1);
                        //   },
                        //   image: 'icon_profile',
                        //   isSelected: _selectedIndex == 1,
                        // ),

                        // NavBarItemWidget(
                        //   onTap: () {},
                        //   image: '',
                        //   isSelected: false,
                        // ),

                        const BottomNavigationBarItem(
                          icon: Icon(
                            Icons.tab,
                            color: Colors.transparent,
                          ),
                          label: '',
                        ),

                        BottomNavigationBarItem(
                          icon: Image.asset(
                            'assets/images/chat.png',
                            height: 25,
                            color: _selectedIndex == 3
                                ? kColorDarkGreen
                                : Colors.grey,
                          ),
                          label: 'Chat',
                        ),
                        BottomNavigationBarItem(
                          icon: Image.asset(
                            'assets/images/community.png',
                            height: 25,
                            color: _selectedIndex == 4
                                ? kColorDarkGreen
                                : Colors.grey,
                          ),
                          label: 'Group chat',
                        ),

                        // NavBarItemWidget(
                        //   onTap: () {
                        //     _selectPage(3);
                        //   },
                        //   image: 'chat',
                        //   isSelected: _selectedIndex == 3,
                        // ),
                        // NavBarItemWidget(
                        //   onTap: () {
                        //     _selectPage(4);
                        //   },
                        //   image: 'community',
                        //   isSelected: _selectedIndex == 4,
                        // ),

                        // NavBarItemWidget(
                        //   onTap: () {
                        //     _selectPage(5);
                        //   },
                        //   image: 'icon_settings',
                        //   isSelected: _selectedIndex == 5,
                        // ),
                      ],
                      onTap: (position) {
                        setState(() {
                          _selectedIndex = position;
                          _pageController.jumpToPage(position);
                        });
                      },
                      currentIndex: _selectedIndex,
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      }
    });
  }
}

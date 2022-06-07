import 'package:bridgemetherapist/NavigatorSerice.dart';
import 'package:bridgemetherapist/controller/ScreeningToolsController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controller/ArticlesController.dart';
import 'controller/CompletedSessions.dart';
import 'controller/HealthConcernController.dart';
import 'controller/JournalController.dart';
import 'controller/MyPatientsController.dart';
import 'controller/PresetsController.dart';
import 'controller/TherapistSessionsController.dart';
import 'controller/PatientsSeenController.dart';
import 'controller/TopPicksController.dart';
import 'controller/UpcomingSessionsController.dart';
import 'routes/route_generator.dart';
import 'routes/routes.dart';
import 'utils/themebloc/theme_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xrcpwmndexxgbjtvorsz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhyY3B3bW5kZXh4Z2JqdHZvcnN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDgzNzQ1NTEsImV4cCI6MTk2Mzk1MDU1MX0.pNirfZMElcrtP0cywqHdumnzCKT6dIlc2UVY497juxc',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    FirebaseMessaging.onMessage.listen((event) {
      RemoteNotification? notification = event.notification;

     // print("message received");
     // print(notification?.toString());
     // print(notification?.title.toString());
     // print(notification?.body.toString());
     // print(event.data);
    });

    //FirebaseMessaging.instance.getToken().then((value) => {print(value)});

    FirebaseMessaging.onMessageOpenedApp.listen((message) {});

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {}
  }

  Get.put(GetStorage());
  Get.put(PresetsController());
  Get.put(JournalController());
  Get.put(TopPicksController());
  Get.put(ArticlesController());
  Get.put(ScreeningToolsController());
  Get.put(HealthConcernController());
  Get.put(TherapistSessionController());
  Get.put(MyPatientsController());
  Get.put(CompletedSessionsController());
  Get.put(UpcomingSessionsController());
  Get.put(PatientsSeenController());

  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: const [
        Locale('en', 'US'),
        //Locale('de', 'DE'),
        //Locale('ar', 'DZ'),
        Locale('es', 'ES'),
        Locale('it', 'IT'),
        Locale('pt', 'PT'),
        //Locale('fr', 'FR'),
      ],
      path: 'assets/languages',
    ),
  );
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

Future<void> _onMessageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: _buildWithTheme,
      ),
    );
  }

  Widget _buildWithTheme(BuildContext context, ThemeState state) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: .8),
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: child!,
          ),
        );
      },
      title: 'BridgeMe',
      initialRoute: Routes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        EasyLocalization.of(context)!.delegate,
      ],
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      locale: EasyLocalization.of(context)!.locale,
      debugShowCheckedModeBanner: false,
      theme: state.themeData,
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

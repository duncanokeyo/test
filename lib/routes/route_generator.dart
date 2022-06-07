import 'package:bridgemetherapist/pages/availability/Availability.dart';
import 'package:bridgemetherapist/pages/availability/SessionsList.dart';
import 'package:bridgemetherapist/pages/story_screen/add_story.dart';
import 'package:bridgemetherapist/pages/story_screen/story_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/appointment/my_appointments_page.dart';
import '../pages/article/articles_list.dart';
import '../pages/chatroom/add_discussion_page.dart';
import '../pages/doctor/PatientsSeen.dart';
import '../pages/doctor/my_patients_list_page.dart';
import '../pages/forgot/forgot_password_page.dart';
import '../pages/home/home.dart';
import '../pages/journals/Journal.dart';
import '../pages/journals/add_journal.dart';
import '../pages/journals/journal_details.dart';
import '../pages/language/change_laguage_page.dart';
import '../pages/login/login_page.dart';
import '../pages/notifications/notification_settings_page.dart';
import '../pages/notifications/notifications_page.dart';
import '../pages/prescription/prescription_detail_page.dart';
import '../pages/profile/edit_profile_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/signup/signup_page.dart';
import '../pages/splash_page.dart';
import '../pages/visit/visit_detail_page.dart';
import 'routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments;

    switch (settings.name) {
      case Routes.splash:
        return CupertinoPageRoute(builder: (_) => SplashPage());

      case Routes.posts:
        return CupertinoPageRoute(builder: (_) => StoryList());
      case Routes.login:
        return CupertinoPageRoute(builder: (_) => LoginPage());

      case Routes.signup:
        return CupertinoPageRoute(builder: (_) => SignupPage());

      case Routes.forgotPassword:
        return CupertinoPageRoute(builder: (_) => ForgotPasswordPage());

      case Routes.home:
        return CupertinoPageRoute(builder: (_) => Home());

      case Routes.articles:
        return CupertinoPageRoute(builder: (_) => ArticlesList());

      case Routes.sessions:
        return CupertinoPageRoute(builder: (_) => SessionsList());

      case Routes.availability:
        return CupertinoPageRoute(
          builder: (_) => Availability(),
          fullscreenDialog: true,
        );

      // case Routes.bookingStep3:
      //   return CupertinoPageRoute(builder: (_) => TimeSlotPage());

      case Routes.bookingStep4:
      // return CupertinoPageRoute(builder: (_) => PatientDetailsPage());

      // case Routes.appointmentDetail:
      //   return CupertinoPageRoute(builder: (_) => AppointmentDetailPage());

      case Routes.visitDetail:
        return CupertinoPageRoute(builder: (_) => VisitDetailPage());

      case Routes.prescriptionDetail:
        return CupertinoPageRoute(builder: (_) => PrescriptionDetailPage());

      //case Routes.chatDetail:
      // return CupertinoPageRoute(builder: (_) => MessagesDetailPage());

      case Routes.settings:
        return CupertinoPageRoute(builder: (_) => SettingsPage());
      case Routes.editProfile:
        return CupertinoPageRoute(builder: (_) => EditProfilePage());

      case Routes.changeLanguage:
        return CupertinoPageRoute(builder: (_) => ChangeLanguagePage());

      case Routes.notificationSettings:
        return CupertinoPageRoute(builder: (_) => NotificationSettingsPage());

      case Routes.myPatients:
        return CupertinoPageRoute(builder: (_) => MyPatientsListPage());

      case Routes.patients_seen:
        return CupertinoPageRoute(builder: (_) => PatientsSeen());

      case Routes.myAppointments:
        return CupertinoPageRoute(builder: (_) => MyAppointmentsPage());

      case Routes.add_story:
        return CupertinoPageRoute(builder: (_) => AddStory());

      case Routes.myJournals:
        return CupertinoPageRoute(builder: (_) => Journal());

      case Routes.add_discussion:
        return CupertinoPageRoute(builder: (_) => AddDiscussionPage());

      case Routes.addJournal:
        return CupertinoPageRoute(builder: (_) => AddJournalPage());

      case Routes.journal_details:
        return CupertinoPageRoute(builder: (_) => JournalDetails());
      case Routes.notifications:
        return CupertinoPageRoute(
          builder: (_) => NotificationsPage(), // case Routes.bookingStep3:
          //   return CupertinoPageRoute(builder: (_) => TimeSlotPage());
          fullscreenDialog: true,
          maintainState: true,
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return CupertinoPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error'),
        ),
      );
    });
  }
}

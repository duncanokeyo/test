// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAuc7E0_rif3iw90EUMx3E0AdtftBPogEo',
    appId: '1:1037132945288:web:fa5cf1a3876aa91f03cc3d',
    messagingSenderId: '1037132945288',
    projectId: 'bridgeme-951cd',
    authDomain: 'bridgeme-951cd.firebaseapp.com',
    storageBucket: 'bridgeme-951cd.appspot.com',
    measurementId: 'G-0JP9T63S3J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9bAV0r8Ldc-L1bQ0f-1ZBXX8guqJkuRA',
    appId: '1:1037132945288:android:b0e1424b2bb4787803cc3d',
    messagingSenderId: '1037132945288',
    projectId: 'bridgeme-951cd',
    storageBucket: 'bridgeme-951cd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvYJSqH98K6yUf-_5BlRPgCZ3BQvbce8Y',
    appId: '1:1037132945288:ios:c132d5670a27b32903cc3d',
    messagingSenderId: '1037132945288',
    projectId: 'bridgeme-951cd',
    storageBucket: 'bridgeme-951cd.appspot.com',
    iosClientId: '1037132945288-at2828da8trp1dmgl4qi0lj9uor8v16b.apps.googleusercontent.com',
    iosBundleId: 'com.bigbrainzsolutions.apps.bridgemetherapist.bridgemetherapist',
  );
}

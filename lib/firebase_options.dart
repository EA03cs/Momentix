// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDWtaTX4SoTUuGOFe5_XYho8Ra2QAySfFs',
    appId: '1:1017960055540:web:0dfa6b0a3fc274897c14a1',
    messagingSenderId: '1017960055540',
    projectId: 'instagram-3dc43',
    authDomain: 'instagram-3dc43.firebaseapp.com',
    storageBucket: 'instagram-3dc43.appspot.com',
    measurementId: 'G-8L82S8HPM4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrZXFpmaXpDLXWjeWhuCkhkopjV5Z5PeI',
    appId: '1:1017960055540:android:40933ede007ec23d7c14a1',
    messagingSenderId: '1017960055540',
    projectId: 'instagram-3dc43',
    storageBucket: 'instagram-3dc43.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhqJZ6UMsg4ElLXF4lWSOrjX4nwPqTjxI',
    appId: '1:1017960055540:ios:a9016e746cf66e867c14a1',
    messagingSenderId: '1017960055540',
    projectId: 'instagram-3dc43',
    storageBucket: 'instagram-3dc43.appspot.com',
    iosBundleId: 'com.example.instaa',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBhqJZ6UMsg4ElLXF4lWSOrjX4nwPqTjxI',
    appId: '1:1017960055540:ios:a9016e746cf66e867c14a1',
    messagingSenderId: '1017960055540',
    projectId: 'instagram-3dc43',
    storageBucket: 'instagram-3dc43.appspot.com',
    iosBundleId: 'com.example.instaa',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDWtaTX4SoTUuGOFe5_XYho8Ra2QAySfFs',
    appId: '1:1017960055540:web:ef8b52c29f713f0c7c14a1',
    messagingSenderId: '1017960055540',
    projectId: 'instagram-3dc43',
    authDomain: 'instagram-3dc43.firebaseapp.com',
    storageBucket: 'instagram-3dc43.appspot.com',
    measurementId: 'G-6PJ7YZNP33',
  );
}

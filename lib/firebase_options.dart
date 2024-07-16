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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB5JXoboYfDvpbh4XFVEzV7BJWBbcSpObA',
    appId: '1:328462257072:web:ec1596fd4eaa96456b2475',
    messagingSenderId: '328462257072',
    projectId: 'finals-flutter-tictactoe',
    authDomain: 'finals-flutter-tictactoe.firebaseapp.com',
    storageBucket: 'finals-flutter-tictactoe.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlIABqN_HXEohklrpLmI1wFIcgWqC3nLg',
    appId: '1:328462257072:android:5832260fdd82b4016b2475',
    messagingSenderId: '328462257072',
    projectId: 'finals-flutter-tictactoe',
    storageBucket: 'finals-flutter-tictactoe.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATMbCTGi42pTnbPmAO-0R3ligGIN2a8Zc',
    appId: '1:328462257072:ios:0d1d8fda111c65486b2475',
    messagingSenderId: '328462257072',
    projectId: 'finals-flutter-tictactoe',
    storageBucket: 'finals-flutter-tictactoe.appspot.com',
    iosBundleId: 'com.example.finalsTictactoeApplication',
  );
}
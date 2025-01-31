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
    apiKey: 'AIzaSyDsCH11TtK6jZbIT8EoH9C7gzjT8ApGbFw',
    appId: '1:155201213192:web:2a065e6e2e787f862f12bd',
    messagingSenderId: '155201213192',
    projectId: 'kidnav-authentication',
    authDomain: 'kidnav-authentication.firebaseapp.com',
    storageBucket: 'kidnav-authentication.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDNfWuLoAEzkKO1pQZYDVt2Bq_gDBsfBik',
    appId: '1:155201213192:android:128d0a4b7690d84a2f12bd',
    messagingSenderId: '155201213192',
    projectId: 'kidnav-authentication',
    storageBucket: 'kidnav-authentication.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmWA6oJk3Zwjj7mSmWgZHWhD1N4d-HwMY',
    appId: '1:155201213192:ios:4b636b5ef194f2182f12bd',
    messagingSenderId: '155201213192',
    projectId: 'kidnav-authentication',
    storageBucket: 'kidnav-authentication.appspot.com',
    iosBundleId: 'com.example.kidnav',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBmWA6oJk3Zwjj7mSmWgZHWhD1N4d-HwMY',
    appId: '1:155201213192:ios:4b636b5ef194f2182f12bd',
    messagingSenderId: '155201213192',
    projectId: 'kidnav-authentication',
    storageBucket: 'kidnav-authentication.appspot.com',
    iosBundleId: 'com.example.kidnav',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDsCH11TtK6jZbIT8EoH9C7gzjT8ApGbFw',
    appId: '1:155201213192:web:6144c2044eca880a2f12bd',
    messagingSenderId: '155201213192',
    projectId: 'kidnav-authentication',
    authDomain: 'kidnav-authentication.firebaseapp.com',
    storageBucket: 'kidnav-authentication.appspot.com',
  );

}
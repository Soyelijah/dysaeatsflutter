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
    apiKey: 'AIzaSyBXlA3J_ws9kUd16RInzpha-UEahsU8iGQ',
    appId: '1:401445581230:web:b3485aeac4cca6f7e6d83f',
    messagingSenderId: '401445581230',
    projectId: 'mensajeria-2bb6d',
    authDomain: 'mensajeria-2bb6d.firebaseapp.com',
    storageBucket: 'mensajeria-2bb6d.firebasestorage.app',
    measurementId: 'G-RMNPE7M7HX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAs6Dh86fG9CSAFi5MIvQ6JtUGLvD_InQ8',
    appId: '1:401445581230:android:0db62527d7e9362ee6d83f',
    messagingSenderId: '401445581230',
    projectId: 'mensajeria-2bb6d',
    storageBucket: 'mensajeria-2bb6d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHzHGfkVy_TAE5Kj-6NpyG5Bo6ZOILFY8',
    appId: '1:401445581230:ios:247a9eb249c46340e6d83f',
    messagingSenderId: '401445581230',
    projectId: 'mensajeria-2bb6d',
    storageBucket: 'mensajeria-2bb6d.firebasestorage.app',
    androidClientId: '401445581230-0i0p77tq7d8r0savmpnq1jog1dg1qfs0.apps.googleusercontent.com',
    iosClientId: '401445581230-r2oqv9rkt87c77h9uts8ojcupspp79v0.apps.googleusercontent.com',
    iosBundleId: 'io.dycompany.dysaeats',
  );
}

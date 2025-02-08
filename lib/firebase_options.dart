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
    apiKey: 'AIzaSyD8RLEs5OQa6IZCAwGELmgsZlIEf2SwBOE',
    appId: '1:182001663311:web:643ae3975d8498812c993a',
    messagingSenderId: '182001663311',
    projectId: 'suqitaizapp',
    authDomain: 'suqitaizapp.firebaseapp.com',
    databaseURL: 'https://suqitaizapp-default-rtdb.firebaseio.com',
    storageBucket: 'suqitaizapp.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAHPErYdzCBOMUTsPIdO81b6M2PJOrAw60',
    appId: '1:182001663311:android:396715970b981f082c993a',
    messagingSenderId: '182001663311',
    projectId: 'suqitaizapp',
    databaseURL: 'https://suqitaizapp-default-rtdb.firebaseio.com',
    storageBucket: 'suqitaizapp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQwKXq0cH-rfYkkCIkMdPQp9em3gfTZWo',
    appId: '1:182001663311:ios:39b8dc40dba8f6312c993a',
    messagingSenderId: '182001663311',
    projectId: 'suqitaizapp',
    databaseURL: 'https://suqitaizapp-default-rtdb.firebaseio.com',
    storageBucket: 'suqitaizapp.appspot.com',
    iosBundleId: 'com.taizdevs.suqi.suqi',
  );
}

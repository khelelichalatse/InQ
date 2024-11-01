import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVOwmkRLff1Qg1uQg4YW-9syfi66HPvR0',
    appId: '1:29833038058:android:31a6a7c15b5315f39cef93',
    messagingSenderId: '29833038058',
    projectId: 'inq-plat',
    storageBucket: 'inq-plat.appspot.com',
    databaseURL: 'https://inq-plat-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBVOwmkRLff1Qg1uQg4YW-9syfi66HPvR0',
    authDomain: 'inq-plat.firebaseapp.com',
    databaseURL: 'https://inq-plat-default-rtdb.firebaseio.com',
    projectId: 'inq-plat',
    storageBucket: 'inq-plat.appspot.com',
    messagingSenderId: '29833038058',
    appId: '1:29833038058:web:31a6a7c15b5315f39cef93',
  );
}

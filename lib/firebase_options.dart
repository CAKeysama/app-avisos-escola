import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurações do Firebase para o projeto `app-sala-avisos`.
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxQIalq1GkLqryuuiyZ3tBrWse8hDLccw',
    appId: '1:577127102013:web:603796bb5b4d2d29c05c54',
    messagingSenderId: '577127102013',
    projectId: 'app-sala-avisos',
    authDomain: 'app-sala-avisos.firebaseapp.com',
    storageBucket: 'app-sala-avisos.firebasestorage.app',
    measurementId: 'G-XQH4DXJ8LV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxQIalq1GkLqryuuiyZ3tBrWse8hDLccw',
    appId: '1:577127102013:android:603796bb5b4d2d29c05c54',
    messagingSenderId: '577127102013',
    projectId: 'app-sala-avisos',
    storageBucket: 'app-sala-avisos.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxQIalq1GkLqryuuiyZ3tBrWse8hDLccw',
    appId: '1:577127102013:ios:603796bb5b4d2d29c05c54',
    messagingSenderId: '577127102013',
    projectId: 'app-sala-avisos',
    storageBucket: 'app-sala-avisos.firebasestorage.app',
    iosBundleId: 'com.example.appSalaAvisos',
  );
}

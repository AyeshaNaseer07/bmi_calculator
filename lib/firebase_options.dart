import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABC11dBj2QxMFOHXResrWCMput9xvsaDA',
    appId: '1:395401843957:android:8ca7da8af69c41ddd721bc',
    messagingSenderId: '395401843957',
    projectId: 'bmi-calculator-cae46',
    storageBucket: 'bmi-calculator-cae46.firebasestorage.app',
  );
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARsvQopPIJ0jKuN2FYheG-siSm7EG6Kcc',
    appId: '1:395401843957:ios:287f2682ea7406b8d721bc',
    messagingSenderId: '395401843957',
    projectId: 'bmi-calculator-cae46',
    storageBucket: 'bmi-calculator-cae46.firebasestorage.app',
    iosBundleId:
        'com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app',
  );
}

//live
//  static const FirebaseOptions ios = FirebaseOptions(
//     apiKey: 'AIzaSyCB0cKtuto6RQCDor_gthYSPMOAqbpQseI',
//     appId: '1:981423509330:ios:ed6b0f8a12f79b75a4348b',
//     messagingSenderId: '981423509330',
//     projectId: 'bmi-calculator-ifunsol',
//     storageBucket: 'bmi-calculator-ifunsol.firebasestorage.app',
//     iosBundleId:
//         'com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app',
//   );

//debug

//  static const FirebaseOptions ios = FirebaseOptions(
//     apiKey: 'AIzaSyARsvQopPIJ0jKuN2FYheG-siSm7EG6Kcc',
//     appId: '1:395401843957:ios:287f2682ea7406b8d721bc',
//     messagingSenderId: '395401843957',
//     projectId: 'bmi-calculator-cae46',
//     storageBucket: 'bmi-calculator-cae46.firebasestorage.app',
//     iosBundleId:
//         'com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app',
//   );

//live firebase

// <?xml version="1.0" encoding="UTF-8"?>
// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// <plist version="1.0">
// <dict>
// 	<key>API_KEY</key>
// 	<string>AIzaSyCB0cKtuto6RQCDor_gthYSPMOAqbpQseI</string>
// 	<key>GCM_SENDER_ID</key>
// 	<string>981423509330</string>
// 	<key>PLIST_VERSION</key>
// 	<string>1</string>
// 	<key>BUNDLE_ID</key>
// 	<string>com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app</string>
// 	<key>PROJECT_ID</key>
// 	<string>bmi-calculator-ifunsol</string>
// 	<key>STORAGE_BUCKET</key>
// 	<string>bmi-calculator-ifunsol.firebasestorage.app</string>
// 	<key>IS_ADS_ENABLED</key>
// 	<false></false>
// 	<key>IS_ANALYTICS_ENABLED</key>
// 	<false></false>
// 	<key>IS_APPINVITE_ENABLED</key>
// 	<true></true>
// 	<key>IS_GCM_ENABLED</key>
// 	<true></true>
// 	<key>IS_SIGNIN_ENABLED</key>
// 	<true></true>
// 	<key>GOOGLE_APP_ID</key>
// 	<string>1:981423509330:ios:ed6b0f8a12f79b75a4348b</string>
// </dict>
// </plist>

//debug firebase

// <?xml version="1.0" encoding="UTF-8"?>
// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// <plist version="1.0">
// <dict>
// 	<key>API_KEY</key>
// 	<string>AIzaSyARsvQopPIJ0jKuN2FYheG-siSm7EG6Kcc</string>
// 	<key>GCM_SENDER_ID</key>
// 	<string>395401843957</string>
// 	<key>PLIST_VERSION</key>
// 	<string>1</string>
// 	<key>BUNDLE_ID</key>
// 	<string>com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app</string>
// 	<key>PROJECT_ID</key>
// 	<string>bmi-calculator-cae46</string>
// 	<key>STORAGE_BUCKET</key>
// 	<string>bmi-calculator-cae46.firebasestorage.app</string>
// 	<key>IS_ADS_ENABLED</key>
// 	<false></false>
// 	<key>IS_ANALYTICS_ENABLED</key>
// 	<false></false>
// 	<key>IS_APPINVITE_ENABLED</key>
// 	<true></true>
// 	<key>IS_GCM_ENABLED</key>
// 	<true></true>
// 	<key>IS_SIGNIN_ENABLED</key>
// 	<true></true>
// 	<key>GOOGLE_APP_ID</key>
// 	<string>1:395401843957:ios:287f2682ea7406b8d721bc</string>
// </dict>
// </plist>

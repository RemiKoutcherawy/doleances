# Doléances
Work in progress...

Cette application gère des doléances dans une liste partagée.\
*This application manages grievances in a shared list.*\
Première version réalisée avec Dart, Flutter, Firebase.\
*This project use Dart, Flutter, Firestore, FlutterFire.*

Google Play : https://play.google.com/store/apps/details?id=rk.doleances \
Apple Store : https://apps.apple.com/fr/app/dol%C3%A9ances/id1587598484 \

# Notes 

    git clone --depth 1 https://github.com/RemiKoutcherawy/doleances 
    cd doleances
    rm -rf ios android
    flutter create .
    open -a /Applications/Android\ Studio.app .
    open ios/Runner.xcworkspace

This page is not a tutorial, just notes.

##1. Configure Android
See https://firebase.flutter.dev/docs/installation/android \
On first launch Android Studio returns errors:
> Cannot fit requested classes in a single dex file (# methods: 94212 > 65536)
> Manifest merger failed : uses-sdk:minSdkVersion 16 cannot be smaller than version 18 declared in library
> Warning: Mapping new ns http://schemas.android.com/repository/android/common/02 to old ns http://schemas.android.com/repository/android/common/01
> E/flutter (11479): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: [core/not-initialized] Firebase has not been correctly initialized. Have you added the "google-services.json" file to the project?

Open `android/app/build.gradle` and add `multiDexEnabled true` in `defaultConfig` :  
> defaultConfig {  
> multiDexEnabled true    // Added
> applicationId "rk.doleances"
> minSdkVersion 18        // Changed from 16 to 18
> targetSdkVersion 30
> versionCode flutterVersionCode.toInteger()
> versionName flutterVersionName
>}

Firebase has not been correctly initialized.
> % cp google-services.json android/app

Edit android/build.gradle
> buildscript {
>   dependencies {
>     // ... other dependencies
>     classpath 'com.google.gms:google-services:4.3.8'    // Added
>   }
> }

Edit android/app/build.gradle
> apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
> apply plugin: 'com.google.gms.google-services'          // Added

Build > Flutter > Build App Bundle \
✓ Built build/app/outputs/bundle/release/app-release.aab (18.5MB). \

> % open -a /Applications/Android\ Studio.app android 

Upload to https://play.google.com/console/ > Créer une release de production \
Choose doleances/android/app/release/app-release.aab
> Le code de version 1 a déjà été utilisé. Choisissez-en un autre.

=> add to doleances/android/local.properties (and not doleances/local.properties)
flutter.versionCode=6\
flutter.versionName=6.0.0\
Build / Rebuild Project\
Build / Generate Signed Bundle  / APK...\

Note 
- Android Emulator Landscape mode \
  Emable auto-rotate inside Emulator (auto-rotate off by default)
- Application launcher icon \
  flutter pub run flutter_launcher_icons:main

##2. Configure iOS
See https://firebase.flutter.dev/docs/installation/ios \
Get `GoogleService-Info.plist` from Firebase console https://console.firebase.google.com/

Cocoapods bugs !

>% pod install  
>/Library/Ruby/Gems/2.6.0/gems/ethon-0.14.0/lib/ethon/curls/classes.rb:36: [BUG] Illegal instruction at 0x0000000104584000

Closed : https://github.com/CocoaPods/CocoaPods/issues/10893 

Cocoapods deprecated settings

> [!] Automatically assigning platform `iOS` with version `9.0` on target `Runner` because no platform was specified. Please specify a platform for this target

FlutterFire bugs
> GeneratedPluginRegistrant.m:10:9: Module 'cloud_firestore' not found
If you know how to fix please tell me...\

Steps: \
`% rm -rf ios `\
`% flutter create . `\
`% cp GoogleService-Info.plist ios/Runner/ `\
`% open ios/Runner.xcworkspace `\
Top left, double clic on Runner to open Editor (File Runner.xcodeproj) \
Runner / Project / Runner / iOS Deployment Target : 14.0 (or 15.0) \
Runner / Targets / Runner / Signing @ Capabilities : => Set Team  \
Runner / Targets / Runner / General / Display Name : Doléances \
Runner / Targets / Runner / General / Bundle identifier : rk.doleances \
flutter pub run flutter_launcher_icons:main

Top left, right clic on Runner \
Add files to "Runner..." \
Select `ios/Runner/Runner/GoogleService-Info.plist`

Top middle, clic on Runner > Edit Scheme... \
On the left clic on Run / Run and select Build Configuration : Release
Take your time...
Xcode build done.  244,8s

Bugs : \
The current Dart SDK version is 2.13.4. \
Because doleances depends on image_picker >=0.8.4+2 which requires SDK version >=2.14.0 <3.0.0, version solving failed. \
=> remove image_picker \
Because shared_preferences 2.0.8 requires SDK version >=2.14.0 <3.0.0 and no versions of shared_preferences match >2.0.8 <3.0.0, shared_preferences ^2.0.8 is forbidden. \
=> remove shared_preferences \
Specs satisfying the `Firebase/Firestore (= 8.6.0), Firebase/Firestore (= 8.8.0)` dependency were found, but they required a higher minimum deployment target.
Error running pod install

💪 Running with sound null safety 💪
Error: Unsupported operation: Platform._operatingSystem\
[...]\
at get isLinux (http://localhost:50865/dart_sdk.js:53404:26)\
at Function.desc.get [as isLinux] (http://localhost:50865/dart_sdk.js:5530:17)\
at flutter_secure_storage.FlutterSecureStorage.new.[_selectOptions] (http://localhost:50865/packages/flutter_secure_storage/flutter_secure_storage.dart.lib.js:160:23)\
=> remove flutter_secure_storage

From https://stackoverflow.com/questions/68434062/flutter-ios-module-cloud-firestore-not-found-in-generatedpluginregistrant/68476434#68476434 \
1/ Delete the Pods directory, the /ios/podfile.lock, and the ios/Flutter/Flutter.podspec \
% rm ./ios \
2/ Run pod deintegrate \
% cd ios \
% pod deintegrate \
Deintegrating `Runner.xcodeproj` \
Removing `Pods` directory. \
Project has been deintegrated. No traces of CocoaPods left in project. \
% cd .. \
3/ Delete all of the contents inside your DerivedData folder.. you can run rm -rf ~/Library/Developer/Xcode/DerivedData/* \
% rm -rf ~/Library/Developer/Xcode/DerivedData/* \
4/ Run flutter clean \
% flutter clean \
5/ Run flutter pub get \
% flutter pub get \
6/ Run flutter build ios. Note thas this will also run the pod install command. \
% flutter build ios \
7/ Close your editor, and open your Runner.xcworkspace on XCode and run your XCode. Clean your build folder. If there's an option to update your project settings, accept it. \
% open ios/Runner.xcworkspace \

##3. Configure Firebase
###3.1 Create Firebase base 
[https://console.firebase.google.com/?hl=fr](https://console.firebase.google.com/?hl=fr)  then :
- Retrieve `google-services.json` and put it in `android/app/` next to `build.gradle`  
- Edit `android/build.gradle` to add `classpath 'com.google.gms:google-services:4.3.10'`  
   > dependencies {  
   > classpath 'com.google.gms:google-services:4.3.10' // Added
- Open `android/app/build.gradle` and add 2 lines :
- Add `apply plugin: 'com.google.gms.google-services'`
  > apply plugin: 'com.android.application'  
  > apply plugin: 'com.google.gms.google-services' // Added 
- Add `implementation platform('com.google.firebase:firebase-bom:28.4.0')`
  > dependencies {  
  >  implementation platform('com.google.firebase:firebase-bom:28.4.0') // Added

###3.2 Register Firebase rules
  Create `rk.doleances` 
  Start in production  mode
  Define Cloud Firestore : eur3 (europe-west)
- Authentification / Sign-in method   
  Activate `Adresse e-mail/Mot de passe` // Mandatory for password reinitialisation \
  Activate `Lien envoyé par e-mail` 
- Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
  match /doleances/{entry} {
      allow read: if true;
      allow write: if (request.auth.uid == 'iQR5zG3KR2NnNTwjp9KFgaoShTF2'
      || request.auth.uid == 'U4W9t7rYlnbLso1fZvdxUe2qQol2');
    }
    match /configuration/{entry} {
      allow read: if true;
      allow write: if (request.auth != null
      && request.auth.uid == 'U4W9t7rYlnbLso1fZvdxUe2qQol2');
    }
    match /fcmTokens/{token} {
      allow read: if false;
      allow write;
    }
  }
}
```

##4. Configure Firebase web
###4.1 Edit web/index.html  
- Add Firebase config retrieved from https://console.firebase.google.com/?hl=fr
```javascript
<body>
//...
<script src="https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.6.1/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.6.1/firebase-firestore.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.10.0/firebase-analytics.js"></script>
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/9.0.1/firebase-app.js";
  const firebaseConfig = {
      //... Here add config
  };
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>
</body>
```

##5. Configure hosting
Minimal configuration

    flutter build web --release
    firebase init // check with space : hosting 
    firebase deploy

% firebase init \
? Which Firebase features do you want to set up for this directory?  \
Hosting: Configure files for Firebase Hosting and (optionally) set up GitHub Action deploys  \
? What do you want to use as your public directory? **build/web**  \
Configure as a single-page app? **y**  \
File build/web/index.html already exists. Overwrite? **N**  \
i  Skipping write of build/web/index.html \
i  Writing configuration info to firebase.json... \
i  Writing project information to .firebaserc... \
% firebase deploy \
i  deploying firestore, hosting \
✔  hosting[doleances-3e828]: release complete\
✔  Deploy complete!\
Project Console: https://console.firebase.google.com/project/doleances-3e828/overview \
Hosting URL: https://doleances-3e828.web.app

##6. Next versions - TODO
For future version v 7 : \
edit pubspec.yaml => version: 7.0.0 \
edit android/app/build.gradle => flutterVersionCode = 7 \
Publish : https://play.google.com/console \
Publish : https://appstoreconnect.apple.com/apps

- Login with Apple ID, or Google ID
- image upload and display
- internationalization for error messages see \
  https://flutter.dev/docs/development/accessibility-and-localization/internationalization
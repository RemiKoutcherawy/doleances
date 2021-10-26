# Doléances
Work in progress...

Cette application gère des doléances dans une liste partagée.\
*This application manages grievances in a shared list.*\
Première version réalisée avec Dart, Flutter, Firebase.\
*This project use Dart, Flutter, Firestore, FlutterFire.*

Google Play : En cours d'examen https://play.google.com/store/apps/details?id=rk.doleances \
Apple Store : Doléances iOS 1.0 En attente de vérification

# For developers

    git clone --depth 1 https://github.com/RemiKoutcherawy/doleances 
    cd doleances
    rm -rf ios android
    flutter create .
    open -a /Applications/Android\ Studio.app .
    open ios/Runner.xcworkspace

Used:\
https://firebase.flutter.dev/docs/installation/android \
https://firebase.flutter.dev/docs/installation/ios/

This page is not a tutorial, just notes.

##1. Configure Android
On first launch Android Studio returns an error:
> Cannot fit requested classes in a single dex file (# methods: 94212 > 65536)

Open `android/app/build.gradle` and add `multiDexEnabled true` in `defaultConfig` :  
> defaultConfig {  
> multiDexEnabled true

##2. Configure iOS
Get `GoogleService-Info.plist` and put it in `doleance/private` (private/ is in .gitignore)

Beware Cocoapods bugs !

>% pod install  
>/Library/Ruby/Gems/2.6.0/gems/ethon-0.14.0/lib/ethon/curls/classes.rb:36: [BUG] Illegal instruction at 0x0000000104584000

Beware Cocoapods deprecated settings !

> [!] Automatically assigning platform `iOS` with version `9.0` on target `Runner` because no platform was specified. Please specify a platform for this target

Beware FlutterFire bugs !
> GeneratedPluginRegistrant.m:10:9: Module 'cloud_firestore' not found
If you know how to fix please tell me...\

Steps: \
`% rm -rf ios `\
`% flutter create . `\
`% cp private/GoogleService-Info.plist ios/Runner/ `\
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

Do NOT update to recommended settings, unless you can manage the errors it generates.\
Top middle, clic on Runner > Edit Scheme... \
On the left clic on Run / Run and select Build Configuration : Release
Take your time...
Xcode build done.  244,8s

Bugs :\
The current Dart SDK version is 2.13.4. \
Because doleances depends on image_picker >=0.8.4+2 which requires SDK version >=2.14.0 <3.0.0, version solving failed. \
=> remove image_picker \
Because shared_preferences 2.0.8 requires SDK version >=2.14.0 <3.0.0 and no versions of shared_preferences match >2.0.8 <3.0.0, shared_preferences ^2.0.8 is forbidden. \
=> remove shared_preferences \

Specs satisfying the `Firebase/Firestore (= 8.6.0), Firebase/Firestore (= 8.8.0)` dependency were found, but they required a higher minimum deployment target.
Error running pod install

💪 Running with sound null safety 💪
Error: Unsupported operation: Platform._operatingSystem
[...]
at get isLinux (http://localhost:50865/dart_sdk.js:53404:26)
at Function.desc.get [as isLinux] (http://localhost:50865/dart_sdk.js:5530:17)
at flutter_secure_storage.FlutterSecureStorage.new.[_selectOptions] (http://localhost:50865/packages/flutter_secure_storage/flutter_secure_storage.dart.lib.js:160:23)
=> remove flutter_secure_storage

From https://stackoverflow.com/questions/68434062/flutter-ios-module-cloud-firestore-not-found-in-generatedpluginregistrant/68476434#68476434
1/ Delete the Pods directory, the /ios/podfile.lock, and the ios/Flutter/Flutter.podspec
% rm ./ios
2/ Run pod deintegrate
% cd ios
% pod deintegrate
Deintegrating `Runner.xcodeproj`
Removing `Pods` directory.
Project has been deintegrated. No traces of CocoaPods left in project.
% cd ..
3/ Delete all of the contents inside your DerivedData folder.. you can run rm -rf ~/Library/Developer/Xcode/DerivedData/*
% rm -rf ~/Library/Developer/Xcode/DerivedData/*
4/ Run flutter clean
% flutter clean
5/ Run flutter pub get
% flutter pub get
6/ Run flutter build ios. Note thas this will also run the pod install command.
% flutter build ios
7/ Close your editor, and open your Runner.xcworkspace on XCode and run your XCode. Clean your build folder. If there's an option to update your project settings, accept it.
% open ios/Runner.xcworkspace


##3. Configure Firebase
###3.1 Create Firebase base [https://console.firebase.google.com/?hl=fr](https://console.firebase.google.com/?hl=fr)  puis :
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
        allow read: if request.auth.uid != null;
        allow write: if request.auth.uid != null;
    }
    match /configuration/{entry} {
        allow read: if true;
        allow write: if request.auth.uid != null;
    }
  }
}
```

##4. Configure Firebase for Web
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
      //...
  };
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>
</body>
```

##5. Configure hosting - TODO
See https://firebase.google.com/docs/hosting?authuser=0   

##6. Next versions - TODO

edit pubspec.yaml => version: 2.0.0 \
edit android/app/build.gradle => flutterVersionCode = 2 \
flutter clean \
flutter pub get \
Build > Flutter > Build App Bundle \
Build > Flutter > Build iOS 
  
Locate : android/app/release/app-release.aab
Locate : build/ios/iphoneos/Runner.app.

Publish : https://play.google.com/console
Publish : https://appstoreconnect.apple.com/apps

- image upload and display
- internationalization for error messages see 
  https://flutter.dev/docs/development/accessibility-and-localization/internationalization
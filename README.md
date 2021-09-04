# Doléances
Cette application gère des doléances dans une liste partagée.  
Le projet est réalisé avec Dart, Flutter, Firestore, FlutterFire.  
Google Play  
Apple Store  
Web 

# Pour les développeurs

    git clone --depth 1 https://github.com/RemiKoutcherawy/doleances 
    cd doleances
    flutter create .
    open -a /Applications/Android\ Studio.app .

##1. Configurer Android
Au premier lancement Android Studio renvoie une erreur :
> Cannot fit requested classes in a single dex file (# methods: 94212 > 65536)

Ouvrir `android/app/build.gradle` et ajouter `multiDexEnabled true` dans `defaultConfig` :  
> defaultConfig {  
> multiDexEnabled true

OK sur émulateur !

##2. Configurer Firebase 

###2.1 Créer la base Firebase [https://console.firebase.google.com/?hl=fr](https://console.firebase.google.com/?hl=fr)  puis :
- Récupérer `google-services.json` et le mettre sous `android/app/` à côté de `build.gradle`  
- Modifier `android/build.gradle` en ajoutant `classpath 'com.google.gms:google-services:4.3.10'`  
   > dependencies {  
   > classpath 'com.google.gms:google-services:4.3.10' // Ajout
- Ouvrir `android/app/build.gradle` et ajouter 2 lignes :
  - Ajouter `apply plugin: 'com.google.gms.google-services'`
  > apply plugin: 'com.android.application'  
  > apply plugin: 'com.google.gms.google-services' // Ajout 
  - Ajouter `implementation platform('com.google.firebase:firebase-bom:28.4.0')`
  > dependencies {  
  >  implementation platform('com.google.firebase:firebase-bom:28.4.0')  // Ajout

###2.2 Enregistrer les règles Firebase  
  Créer `rk.doleances`  
  Démarrer en mode production  
  Définir l’emplacement Cloud Firestore : eur3 (europe-west)
- Authentification / Sign-in method   
  Activer `Adresse e-mail/Mot de passe` // Obligatoire pour la réinitialisation du mot de passe  
  Activer `Lien envoyé par e-mail` (connexion sans mot de passe)
- Règles
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

##3. Configurer Firebase pour Web
###3.1 Corriger web/index.html  
- Remplacer `href="/"` par `href="/web/"`  
- Ajouter la config Firebase récupérée sur https://console.firebase.google.com/?hl=fr
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
OK en local sur Chrome !

##4. Configurer Firebase pour iOS - TODO
Récupérer `GoogleService-Info.plist` et le mettre sous `ios/Runner/`  
`flutter create -i swift .`  
`flutter build ios`  
`open ios/Runner.xcworkspace`  
Attention Cocoapods bugue !
>% pod install  
>/Library/Ruby/Gems/2.6.0/gems/ethon-0.14.0/lib/ethon/curls/classes.rb:36: [BUG] Illegal instruction at 0x0000000104584000
  
Ne marche pas encore !

##5. Configurer l’hébergement - TODO
Voir https://firebase.google.com/docs/hosting?authuser=0   
Ne marche pas encore !

##6. Prochaines versions - TODO
- style avec Theme
- image à charger et à afficher pour tous 
- notification à envoyer dès qu’une modification est enregistrée  
  https://firebase.google.com/codelabs/firebase-web#0
- internationalisation surtout des messages d'erreur voir  
  https://flutter.dev/docs/development/accessibility-and-localization/internationalization

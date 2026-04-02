# 🔥 INSTRUCTIONS FINALES - INTÉGRATION FIREBASE MBOKA CARE

## ✅ CE QUI A ÉTÉ FAIT AUTOMATIQUEMENT

1. ✅ `firebase_options.dart` créé dans `lib/`
2. ✅ Dépendances Firebase ajoutées dans `pubspec.yaml`
3. ✅ `android/build.gradle` modifié (Google Services plugin)
4. ✅ `android/app/build.gradle` modifié (apply plugin, minSdk, multiDex)
5. ✅ Service d'authentification créé (`lib/services/firebase_auth_service.dart`)
6. ✅ Providers Riverpod créés (`lib/providers/auth_provider.dart`)

## ⚠️ CE QUE VOUS DEVEZ FAIRE MANUELLEMENT

### 📥 ÉTAPE 1 : Télécharger google-services.json

1. Allez sur : https://console.firebase.google.com/
2. Cliquez sur votre projet **"MBOKA-CARE"**
3. ⚙️ Paramètres → Paramètres du projet
4. Onglet "Vos applications"
5. Section Android (com.mbokacare.mboka_care_mobile)
6. Cliquez sur "google-services.json"
7. **Téléchargez le fichier**
8. **Placez-le dans** : `C:\Users\LENOVO\Downloads\mboka-care-mobile\android\app\google-services.json`

⚠️ **CRITIQUE** : Le fichier DOIT être dans `android/app/`, pas ailleurs !

---

### 🔑 ÉTAPE 2 : Remplacer l'API Key

1. Ouvrez le fichier `google-services.json` que vous venez de télécharger
2. Cherchez la ligne : `"current_key": "AIzaSy..."`
3. Copiez cette valeur (commence par `AIzaSy`)
4. Ouvrez `lib/firebase_options.dart`
5. Remplacez `API_KEY_TO_REPLACE` par la vraie clé :

```dart
apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXX', // Collez ici
```

---

### 📦 ÉTAPE 3 : Installer les packages

Dans le terminal VS Code :

```bash
flutter pub get
```

---

### 🔧 ÉTAPE 4 : Modifier main.dart

Ouvrez `lib/main.dart` et modifiez comme suit :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

// ✅ AJOUTEZ CET IMPORT
import 'firebase_options.dart';

void main() async {
  // ✅ OBLIGATOIRE pour Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ... reste de votre code ...
```

---

### ✅ ÉTAPE 5 : Activer les services Firebase Console

#### A) Authentication
1. Firebase Console → Authentication
2. Cliquez "Commencer"
3. Activez "E-mail/Mot de passe"

#### B) Firestore Database
1. Firebase Console → Firestore Database
2. Cliquez "Créer une base de données"
3. Mode : "Mode test"
4. Emplacement : "europe-west1"

#### C) Storage
1. Firebase Console → Storage
2. Cliquez "Commencer"
3. Mode : "Mode test"
4. Emplacement : "europe-west1"

---

### 🧪 ÉTAPE 6 : Tester

```bash
flutter run
```

Si l'app démarre sans erreur → ✅ Firebase est configuré !

Pour vérifier, ajoutez dans `main.dart` après `Firebase.initializeApp()` :

```dart
print('✅ Firebase initialisé !');
print('Project ID: ${Firebase.app().options.projectId}');
```

Vous devriez voir dans les logs :
```
✅ Firebase initialisé !
Project ID: mboka-care
```

---

## 🎯 PROCHAINES ÉTAPES

Maintenant que Firebase est configuré, vous pouvez :

1. Utiliser `FirebaseAuthService` pour l'authentification
2. Créer vos écrans d'inscription/connexion
3. Utiliser les providers Riverpod créés
4. Implémenter le scan QR Code
5. Ajouter l'upload de documents

---

## 🆘 BESOIN D'AIDE ?

Si vous rencontrez des erreurs :
- Vérifiez que `google-services.json` est dans `android/app/`
- Vérifiez que l'API Key est correcte dans `firebase_options.dart`
- Exécutez `flutter clean` puis `flutter pub get`

---

**🔥 Bon courage Guillaume ! Firebase est presque prêt ! 🚀**

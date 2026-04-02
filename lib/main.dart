import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/routes.dart';
import 'core/storage/local_storage.dart';
import 'core/services/notification_service.dart';
import 'core/network/api_client.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  _registerFcmToken();
  runApp(const ProviderScope(child: MbokaCareApp()));
}

/// Enregistre le token FCM sur le backend si l'utilisateur est connecté.
/// Appelé au démarrage — silencieux en cas d'échec.
Future<void> _registerFcmToken() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    final userToken = LocalStorage.getAccessToken();
    if (userToken == null) return; // pas connecté
    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID';
    await ApiClient().registerPushToken({'token': token, 'platform': platform});
  } catch (_) {}
}

class MbokaCareApp extends StatelessWidget {
  const MbokaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mboka Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

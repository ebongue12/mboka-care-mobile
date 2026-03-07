import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(const ProviderScope(child: MbokaCareApp()));
}

class MbokaCareApp extends StatelessWidget {
  const MbokaCareApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MBOKA-CARE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2196F3)),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

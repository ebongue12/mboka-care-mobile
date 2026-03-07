import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/patient/screens/patient_dashboard_screen.dart';
import '../features/qr_code/screens/qr_code_screen.dart';
import '../features/qr_code/screens/scanner_screen.dart';
import '../features/reminders/screens/reminders_screen.dart';
import '../features/reminders/screens/add_reminder_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/documents/screens/upload_document_screen.dart';
import '../features/health_priority/screens/health_priority_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String patientDashboard = '/dashboard';
  static const String qrCode = '/qr-code';
  static const String scanner = '/scanner';
  static const String reminders = '/reminders';
  static const String addReminder = '/add-reminder';
  static const String documents = '/documents';
  static const String uploadDocument = '/upload-document';
  static const String healthPriority = '/health-priority';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash: return _r(const SplashScreen());
      case onboarding: return _r(const OnboardingScreen());
      case login: return _r(const LoginScreen());
      case register: return _r(const RegisterScreen());
      case patientDashboard: return _r(const PatientDashboardScreen());
      case qrCode: return _r(const QrCodeScreen());
      case scanner: return _r(const ScannerScreen());
      case reminders: return _r(const RemindersScreen());
      case addReminder: return _r(const AddReminderScreen());
      case documents: return _r(const DocumentsScreen());
      case uploadDocument: return _r(const UploadDocumentScreen());
      case healthPriority: return _r(const HealthPriorityScreen());
      default: return _r(Scaffold(body: Center(child: Text('Route inconnue: ${settings.name}'))));
    }
  }
  static MaterialPageRoute _r(Widget w) => MaterialPageRoute(builder: (_) => w);
}

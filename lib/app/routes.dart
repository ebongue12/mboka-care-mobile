import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/screens/auth_choice_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/patient/screens/patient_dashboard_screen.dart';
import '../features/patient/screens/consultation_history_screen.dart';
import '../features/qr_code/screens/qr_code_screen.dart';
import '../features/qr_code/screens/scanner_screen.dart';
import '../features/qr_code/screens/qr_update_prompt_screen.dart';
import '../features/qr_code/screens/qr_card_preview_screen.dart';
import '../features/reminders/screens/reminders_screen.dart';
import '../features/reminders/screens/add_reminder_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/documents/screens/upload_document_screen.dart';
import '../features/health_priority/screens/health_priority_screen.dart';
import '../features/family/screens/family_list_screen.dart';
import '../features/sharing/screens/followers_list_screen.dart';
import '../features/medecin/screens/scan_qr_screen.dart';
import '../features/healthcare_staff/screens/staff_dashboard_screen.dart';
import '../features/healthcare_staff/screens/staff_register_screen.dart';
import '../features/auth/screens/role_selector_screen.dart';
import '../features/health_tips/screens/health_tips_screen.dart';

class AppRoutes {
  // ─── Patient ────────────────────────────────────────────────────
  static const String splash          = '/';
  static const String onboarding      = '/onboarding';
  static const String authChoice      = '/auth';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String patientDashboard = '/dashboard';
  static const String qrCode          = '/qr-code';
  static const String qrUpdatePrompt  = '/qr-update';
  static const String qrCard          = '/qr-card';
  static const String reminders       = '/reminders';
  static const String addReminder     = '/add-reminder';
  static const String documents       = '/documents';
  static const String uploadDocument  = '/upload-document';
  static const String healthPriority  = '/health-priority';
  static const String family          = '/family';
  static const String followers       = '/followers';
  static const String consultHistory  = '/consultation-history';
  static const String healthTips      = '/health-tips';

  // ─── Médecin (legacy) / Personnel de Santé ──────────────────────
  static const String medecinDashboard  = '/medecin';
  static const String medecinScanQr     = '/medecin/scan';
  static const String staffDashboard    = '/staff';
  static const String staffRegister     = '/staff/register';
  static const String roleSelector      = '/role-selector';

  // ─── Scanner (médecin uniquement via medecinScanQr) ─────────────
  static const String scanner = '/scanner';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:           return _r(const SplashScreen());
      case onboarding:       return _r(const OnboardingScreen());
      case authChoice:       return _r(const AuthChoiceScreen());
      case roleSelector:     return _r(const RoleSelectorScreen());
      case login:
        final args = settings.arguments as Map<String, dynamic>?;
        return _r(LoginScreen(roleFromSelector: args?['role']?.toString()));
      case register:         return _r(const RegisterScreen());
      case patientDashboard: return _r(const PatientDashboardScreen());
      case qrCode:           return _r(const QrCodeScreen());
      case qrUpdatePrompt:   return _r(const QrUpdatePromptScreen());
      case qrCard:           return _r(const QrCardPreviewScreen());
      case scanner:          return _r(const ScannerScreen());
      case reminders:        return _r(const RemindersScreen());
      case addReminder:      return _r(const AddReminderScreen());
      case documents:        return _r(const DocumentsScreen());
      case uploadDocument:   return _r(const UploadDocumentScreen());
      case healthPriority:   return _r(const HealthPriorityScreen());
      case family:           return _r(const FamilyListScreen());
      case followers:        return _r(const FollowersListScreen());
      case consultHistory:   return _r(const ConsultationHistoryScreen());
      case healthTips:       return _r(const HealthTipsScreen());
      case medecinDashboard: return _r(const StaffDashboardScreen());
      case medecinScanQr:    return _r(const MedecinScanQrScreen());
      case staffDashboard:   return _r(const StaffDashboardScreen());
      case staffRegister:    return _r(const StaffRegisterScreen());
      default:               return _r(Scaffold(
          body: Center(
              child: Text('Route inconnue: ${settings.name}'))));
    }
  }

  static MaterialPageRoute _r(Widget w) =>
      MaterialPageRoute(builder: (_) => w);
}

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../app/constants.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          LocalStorage.clearTokens();
        }
        return handler.next(error);
      },
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      responseBody: true,
      compact: true,
    ));
  }

  Dio get dio => _dio;

  // ─── Auth ─────────────────────────────────────────────────────
  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post('/accounts/register/', data: data);

  Future<Response> login(Map<String, dynamic> data) =>
      _dio.post('/accounts/login/', data: data);

  Future<Response> logout() =>
      _dio.post('/accounts/logout/');

  // ─── Patient ──────────────────────────────────────────────────
  Future<Response> getPatientProfile() =>
      _dio.get('/patients/me/');

  Future<Response> updatePatientProfile(Map<String, dynamic> data) =>
      _dio.put('/patients/me/', data: data);

  Future<Response> generatePatientQR() =>
      _dio.get('/patients/qr/generate/');

  Future<Response> getPatientQR() =>
      _dio.get('/patients/qr/');

  Future<Response> updateHealthStatus(Map<String, dynamic> data) =>
      _dio.post('/patients/health-status-update/', data: data);

  Future<Response> getConsultationHistory() =>
      _dio.get('/patients/consultation-history/');

  Future<Response> reportAbuse(Map<String, dynamic> data) =>
      _dio.post('/patients/report-abuse/', data: data);

  // ─── Documents ────────────────────────────────────────────────
  // Base URL = /api → /medical/documents/ = /api/medical/documents/ ✓
  Future<Response> getDocuments() =>
      _dio.get('/medical/documents/');

  Future<Response> uploadDocument(FormData formData) =>
      _dio.post('/medical/documents/', data: formData,
          options: Options(contentType: 'multipart/form-data'));

  // ─── Rappels ──────────────────────────────────────────────────
  // Base URL = /api → /reminders/ = /api/reminders/ ✓
  Future<Response> getReminders() =>
      _dio.get('/reminders/');

  Future<Response> createReminder(Map<String, dynamic> data) =>
      _dio.post('/reminders/', data: data);

  // ─── Famille ──────────────────────────────────────────────────
  // family-members est sous /api/patients/ donc → /patients/family-members/
  Future<Response> getFamilyMembers() =>
      _dio.get('/patients/family-members/');

  Future<Response> addFamilyMember(Map<String, dynamic> data) =>
      _dio.post('/patients/family-members/', data: data);

  Future<Response> updateFamilyMember(String id, Map<String, dynamic> data) =>
      _dio.put('/patients/family-members/$id/', data: data);

  Future<Response> deleteFamilyMember(String id) =>
      _dio.delete('/patients/family-members/$id/');

  // ─── Suiveurs ─────────────────────────────────────────────────
  // followers est sous /api/sharing/ donc → /sharing/followers/
  Future<Response> getFollowers() =>
      _dio.get('/sharing/followers/');

  Future<Response> addFollower(Map<String, dynamic> data) =>
      _dio.post('/sharing/followers/', data: data);

  Future<Response> removeFollower(String id) =>
      _dio.delete('/sharing/followers/$id/');

  // ─── Personnel de Santé ───────────────────────────────────────
  // Base URL = /api → /healthcare/ = /api/healthcare/ ✓ (sans double /api/)
  Future<Response> getHealthcareProfile() =>
      _dio.get('/healthcare/me/');

  Future<Response> healthcareScanQR(Map<String, dynamic> data) =>
      _dio.post('/healthcare/scan-qr/', data: data);

  Future<Response> getHealthcareFollowedPatients() =>
      _dio.get('/healthcare/followed-patients/');

  Future<Response> healthcareFollowPatient(Map<String, dynamic> data) =>
      _dio.post('/healthcare/follow-patient/', data: data);

  Future<Response> getHealthcareStats() =>
      _dio.get('/healthcare/statistics/');

  Future<Response> registerHealthcareStaff(FormData formData) =>
      _dio.post('/healthcare/register/', data: formData,
          options: Options(contentType: 'multipart/form-data'));

  // ─── Médecin (scan via doctors) ───────────────────────────────
  Future<Response> doctorScanQR(Map<String, dynamic> data) =>
      _dio.post('/doctors/scan-qr/', data: data);

  // ─── Notifications ────────────────────────────────────────────
  Future<Response> getNotifications() =>
      _dio.get('/notifications/');
}

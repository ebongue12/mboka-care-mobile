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
        'Accept': 'application/json'
      },
    ));

    // Intercepteur pour ajouter le token JWT
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Gérer les erreurs 401 (token expiré)
        if (error.response?.statusCode == 401) {
          // TODO: Implémenter refresh token si nécessaire
          LocalStorage.clearTokens();
        }
        return handler.next(error);
      },
    ));

    // Logger pour le debug
    _dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      responseBody: true,
      compact: true
    ));
  }

  Dio get dio => _dio;

  // Authentification (endpoints Django)
  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/accounts/register/', data: data);
  }

  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post('/accounts/login/', data: data);
  }

  Future<Response> logout() async {
    return await _dio.post('/accounts/logout/');
  }

  // Patients
  Future<Response> getPatientProfile() async {
    return await _dio.get('/patients/me/');
  }

  Future<Response> updatePatientProfile(Map<String, dynamic> data) async {
    return await _dio.put('/patients/me/', data: data);
  }

  Future<Response> generatePatientQR() async {
    return await _dio.get('/patients/qr/generate/');
  }

  // Documents médicaux
  Future<Response> getDocuments() async {
    return await _dio.get('/medical/documents/');
  }

  Future<Response> uploadDocument(FormData formData) async {
    return await _dio.post('/medical/documents/', data: formData);
  }

  // Rappels
  Future<Response> getReminders() async {
    return await _dio.get('/reminders/');
  }

  Future<Response> createReminder(Map<String, dynamic> data) async {
    return await _dio.post('/reminders/', data: data);
  }

  // Notifications
  Future<Response> getNotifications() async {
    return await _dio.get('/notifications/');
  }
}

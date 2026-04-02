import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState({required this.status, this.user, this.errorMessage});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? errorMessage}) =>
    AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;

  AuthNotifier(this._api) : super(AuthState(status: AuthStatus.initial)) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final token = LocalStorage.getAccessToken();
    state = state.copyWith(
      status: token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  Future<bool> login({required String phone, required String password}) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final response = await _api.login({'phone': phone, 'password': password});

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Sauvegarder les tokens JWT
        final accessToken = data['access']?.toString() ?? data['token']?.toString();
        if (accessToken != null) await LocalStorage.saveAccessToken(accessToken);

        final refreshToken = data['refresh']?.toString();
        if (refreshToken != null) await LocalStorage.saveRefreshToken(refreshToken);

        // Sauvegarder les infos utilisateur
        UserModel? user;
        if (data['user'] is Map) {
          user = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
          await LocalStorage.saveUserId(user.id);
          await LocalStorage.saveUserRole(user.role);
        }

        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Téléphone ou mot de passe incorrect',
      );
      return false;
    } on DioException catch (e) {
      String msg = 'Erreur de connexion. Vérifiez votre réseau.';
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        final data = e.response?.data;
        if (data is Map) {
          msg = data['detail']?.toString() ??
                data['non_field_errors']?.toString() ??
                'Téléphone ou mot de passe incorrect';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        msg = 'Le serveur met du temps à répondre. Veuillez patienter.';
      }
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Erreur inattendue. Réessayez.',
      );
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final response = await _api.register(data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = response.data as Map<String, dynamic>;

        final accessToken = resData['access']?.toString() ?? resData['token']?.toString();
        if (accessToken != null) await LocalStorage.saveAccessToken(accessToken);

        final refreshToken = resData['refresh']?.toString();
        if (refreshToken != null) await LocalStorage.saveRefreshToken(refreshToken);

        UserModel? user;
        if (resData['user'] is Map) {
          user = UserModel.fromJson(Map<String, dynamic>.from(resData['user']));
          await LocalStorage.saveUserId(user.id);
          await LocalStorage.saveUserRole(user.role);
        }

        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      }

      state = state.copyWith(status: AuthStatus.error, errorMessage: "Erreur d'inscription");
      return false;
    } on DioException catch (e) {
      String msg = 'Ce numéro est déjà utilisé ou erreur réseau';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['detail']?.toString() ??
              d['phone']?.toString() ??
              d['email']?.toString() ??
              msg;
      }
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Erreur inattendue. Réessayez.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try { await _api.logout(); } catch (_) {}
    await LocalStorage.clearAll();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(apiClientProvider)),
);

class AppConstants {
  // URL du backend Django sur Render
  static const String baseUrl = 'https://mboka-care-api.onrender.com';
  static const String apiBaseUrl = '$baseUrl/api';
  
  // Tokens d'authentification
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  
  // Timeouts (Render peut prendre 30-60s au réveil)
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}

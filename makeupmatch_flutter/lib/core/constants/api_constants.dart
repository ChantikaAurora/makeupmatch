class ApiConstants {
  // static const String baseUrl = 'http://192.168.0.110:5000'; // Server 1
  static const String baseUrl = 'http://192.168.0.108:5000'; // Server 2

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';

  // Recommend
  static const String recommend = '/api/recommend';
  static const String history = '/api/history';

  // Makeup
  static const String makeupTypes = '/api/makeup-types';
  static const String makeupDetail = '/api/makeup-types/';

  // Profile
  static const String profile = '/api/profile';

  // Image base URL
  static String get imageBaseUrl => '$baseUrl/static/makeup_images';
}
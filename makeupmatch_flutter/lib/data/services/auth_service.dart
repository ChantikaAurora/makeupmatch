import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/storage_helper.dart';

class AuthService {
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await StorageHelper.saveToken(data['access_token']);
      await StorageHelper.saveUser(
        id: data['user']['id'].toString(),
        nama: data['user']['nama'],
        email: data['user']['email'],
      );
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  // Registrasi Tahap 1: Kirim Data untuk Request OTP
  static Future<void> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  // Registrasi Tahap 2: Verifikasi OTP ke Backend
  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Verifikasi OTP gagal');
    }
  }

  // Lupa Password / Reset Password langsung
  static Future<void> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': newPassword}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memperbarui password');
    }
  }

  // Google Sign In (Simulasi / Mockup Integrasi)
  static Future<void> loginWithGoogle({
    required String email,
    required String nama,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'nama': nama}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await StorageHelper.saveToken(data['access_token']);
      await StorageHelper.saveUser(
        id: data['user']['id'].toString(),
        nama: data['user']['nama'],
        email: data['user']['email'],
      );
    } else {
      throw Exception(data['message'] ?? 'Google Sign In Gagal');
    }
  }

  static Future<void> logout() async {
    final token = await StorageHelper.getToken();
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    await StorageHelper.clearAll();
  }
}
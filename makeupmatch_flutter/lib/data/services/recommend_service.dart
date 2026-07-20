import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/storage_helper.dart';
import '../models/recommendation_model.dart';

class RecommendService {
  static Future<Map<String, dynamic>> getRecommendation({
    required String faceShape,
    required String eyeType,
    required String noseShape,
    required String lipShape,
    required String eyebrowShape,
    required String skinTone,
  }) async {
    final token = await StorageHelper.getToken();
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.recommend}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'face_shape': faceShape,
              'eye_type': eyeType,
              'nose_shape': noseShape,
              'lip_shape': lipShape,
              'eyebrow_shape': eyebrowShape,
              'skin_tone': skinTone,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception(
        'Server tidak merespons dalam 15 detik. Cek apakah backend Flask '
        'masih berjalan dan IP di ApiConstants.baseUrl (${ApiConstants.baseUrl}) '
        'masih sesuai dengan IP Mac kamu saat ini.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Tidak bisa terhubung ke server ($e). Pastikan iPhone dan Mac '
        'terhubung ke WiFi yang sama.',
      );
    }

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal mendapatkan rekomendasi');
    }
  }

  static Future<List<RecommendationModel>> getHistory() async {
    final token = await StorageHelper.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.history}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RecommendationModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil riwayat');
    }
  }
}
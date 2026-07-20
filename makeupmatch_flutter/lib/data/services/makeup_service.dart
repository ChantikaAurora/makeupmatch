import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/storage_helper.dart';
import '../models/user_model.dart';

class MakeupService {
  static Future<List<MakeupTypeModel>> getMakeupTypes() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.makeupTypes}'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MakeupTypeModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data makeup');
    }
  }

  static Future<MakeupTypeModel> getMakeupDetail(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.makeupDetail}$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MakeupTypeModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail makeup');
    }
  }
}
import '../../core/constants/api_constants.dart';

class MakeupTypeModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String tips;
  final String? imageUrl;
  final String? createdAt;

  MakeupTypeModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.tips,
    this.imageUrl,
    this.createdAt,
  });

  factory MakeupTypeModel.fromJson(Map<String, dynamic> json) {
    return MakeupTypeModel(
      id: json['id'],
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tips: json['tips'] ?? '',
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }
  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    return Uri.encodeFull('${ApiConstants.baseUrl}$imageUrl');
  }
}
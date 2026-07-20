import '../../core/constants/api_constants.dart';

class RecommendationModel {
  final int id;
  final String faceShape;
  final String eyeType;
  final String skinTone;
  final String top1Nama;
  final String? top1ImageUrl;
  final double top1Score;
  final String createdAt;

  RecommendationModel({
    required this.id,
    required this.faceShape,
    required this.eyeType,
    required this.skinTone,
    required this.top1Nama,
    this.top1ImageUrl,
    required this.top1Score,
    required this.createdAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'],
      faceShape: json['face_shape'] ?? '',
      eyeType: json['eye_type'] ?? '',
      skinTone: json['skin_tone'] ?? '',
      top1Nama: json['top1_nama'] ?? '',
      top1ImageUrl: json['top1_image_url'],
      top1Score: (json['top1_score'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
    );
  }

  String? get fullImageUrl {
    if (top1ImageUrl == null || top1ImageUrl!.isEmpty) return null;
    return Uri.encodeFull('${ApiConstants.baseUrl}$top1ImageUrl');
  }
}
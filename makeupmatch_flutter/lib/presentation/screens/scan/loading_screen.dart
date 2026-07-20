import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/face_analysis_service.dart';
import '../../../data/services/recommend_service.dart';
import 'result_screen.dart';

/// Menjalankan pipeline on-device sesungguhnya (Gambar 3.3):
/// deteksi wajah (sudah didapat dari pick_source_screen) -> klasifikasi
/// bentuk wajah (MobileNetV2) -> analisis skin tone (CIELAB) -> hitung rasio
/// hidung/bibir/alis -> kirim 6 fitur ke `/api/recommend`.
///
/// Foto TIDAK PERNAH dikirim ke server -- hanya hasil FaceFeatures (angka +
/// label kecil) yang dikirim lewat RecommendService.
class LoadingScreen extends StatefulWidget {
  final String imagePath;
  final String eyeType;
  final Face face;

  const LoadingScreen({
    super.key,
    required this.imagePath,
    required this.eyeType,
    required this.face,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _currentStep = 0;
  double _progress = 0;

  final List<String> _steps = [
    'Deteksi fitur wajah',
    'Klasifikasi bentuk wajah',
    'Analisis skin tone & rasio fitur',
    'Cocokkan rekomendasi',
  ];

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  void _advance(int step) {
    if (!mounted) return;
    setState(() {
      _currentStep = step;
      _progress = step / _steps.length;
    });
  }

  Future<void> _startProcess() async {
    try {
      // Step 1: wajah + contour sudah didapat sebelumnya (widget.face) saat
      // validasi "Foto Valid?" di pick_source_screen.dart.
      _advance(1);
      await Future.delayed(const Duration(milliseconds: 200));

      // Step 2 & 3: jalankan ekstraksi 5 fitur on-device (bentuk wajah,
      // hidung, bibir, alis, skin tone) -- kerja berat (tflite + sampling
      // piksel), dijalankan sungguhan (bukan delay palsu).
      final features = await FaceAnalysisService.analyzeFeatures(
        imagePath: widget.imagePath,
        face: widget.face,
      );
      _advance(3);

      // Step 4: kirim 6 fitur (bukan foto) ke backend, simpan otomatis ke
      // riwayat, dapatkan top-1/top-2 rekomendasi.
      final result = await RecommendService.getRecommendation(
        faceShape: features.faceShape,
        eyeType: widget.eyeType,
        noseShape: features.noseShape,
        lipShape: features.lipShape,
        eyebrowShape: features.eyebrowShape,
        skinTone: features.skinTone,
      );
      _advance(4);
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (e) {
      debugPrint('analyzeFeatures/getRecommendation error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menganalisis wajah: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.divider,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Menganalisis...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mohon tunggu sebentar',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              ..._steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final step = entry.value;
                final isDone = idx < _currentStep;
                final isCurrent = idx == _currentStep - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppTheme.success
                              : isCurrent
                                  ? AppTheme.primary
                                  : AppTheme.divider,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDone || isCurrent
                              ? AppTheme.textPrimary
                              : AppTheme.textHint,
                          fontWeight: isDone || isCurrent
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Spacer(),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppTheme.divider,
                      color: AppTheme.primary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).round()}% selesai',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

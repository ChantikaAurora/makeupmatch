import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/face_analysis_service.dart';
import 'eye_type_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PickSourceScreen extends StatelessWidget {
  const PickSourceScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;
      if (!context.mounted) return;

      // Validasi "Foto Valid?" (§8): jalankan deteksi wajah on-device di
      // sini, SEBELUM lanjut ke layar berikutnya. Kalau tidak ada wajah
      // terdeteksi, user tetap di layar ini ("Ulangi Foto").
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final face = await FaceAnalysisService.detectSingleFace(picked.path);
        if (!context.mounted) return;
        Navigator.pop(context); // tutup dialog loading validasi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EyeTypeScreen(imagePath: picked.path, face: face),
          ),
        );
      } catch (e) {
        // Log error asli ke console (bukan cuma pesan generik ke user) supaya
        // gampang dibedakan: benar-benar wajah tidak valid, atau error lain
        // (mis. exception dari plugin/native code).
        debugPrint('detectSingleFace error: $e');
        if (!context.mounted) return;
        Navigator.pop(context); // tutup dialog loading validasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Foto tidak valid: pastikan wajah terlihat jelas, frontal, dan '
              'pencahayaan cukup. Silakan ulangi foto.',
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Pilih Foto'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Bagaimana cara mengambil foto wajah Anda?',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Kamera
            _SourceCard(
              icon: Icons.camera_alt_outlined,
              title: 'Kamera',
              subtitle: 'Ambil foto langsung',
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),

            // Galeri
            _SourceCard(
              icon: Icons.photo_library_outlined,
              title: 'Galeri',
              subtitle: 'Pilih foto tersimpan',
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
            const SizedBox(height: 28),

            // Tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.accent,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'TIPS FOTO TERBAIK',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Wajah menghadap kamera secara frontal',
                    'Pencahayaan cukup dan merata',
                    'Tanpa kacamata atau masker',
                    'Ekspresi netral',
                    'Rambut tidak menutupi wajah',
                  ].map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 10, top: 1),
                            decoration: const BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import 'loading_screen.dart';

class EyeTypeScreen extends StatefulWidget {
  final String imagePath;
  final Face face;

  const EyeTypeScreen({super.key, required this.imagePath, required this.face});

  @override
  State<EyeTypeScreen> createState() => _EyeTypeScreenState();
}

class _EyeTypeScreenState extends State<EyeTypeScreen> {
  String? _selectedEyeType;

  final List<Map<String, String>> _eyeTypes = [
    {
      'value': 'Monolid',
      'label': 'Monolid',
      'desc': 'Tidak ada lipatan kelopak mata',
    },
    {
      'value': 'Double Eyelid',
      'label': 'Double Eyelid',
      'desc': 'Ada lipatan kelopak mata yang terlihat',
    },
    {
      'value': 'Hooded',
      'label': 'Hooded',
      'desc': 'Lipatan kelopak tersembunyi saat mata terbuka',
    },
  ];

  Widget _buildImagePlaceholder() {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.face_retouching_natural_outlined,
              size: 54,
              color: AppTheme.primary,
            ),
            SizedBox(height: 12),
            Text(
              'Gagal memuat foto',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Wajah',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    kIsWeb
                        ? Image.network(
                            widget.imagePath,
                            width: double.infinity,
                            height: 320,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          )
                        : Image.file(
                            File(widget.imagePath),
                            width: double.infinity,
                            height: 320,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          ),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Fitur Wajah Terdeteksi',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Tipe Kelopak Mata',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih karakteristik mata yang paling sesuai dengan Anda',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            ..._eyeTypes.map(
              (eye) {
                final isSelected = _selectedEyeType == eye['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.03) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.divider.withOpacity(0.6),
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _selectedEyeType = eye['value']),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: eye['value']!,
                              groupValue: _selectedEyeType,
                              onChanged: (v) => setState(() => _selectedEyeType = v),
                              activeColor: AppTheme.primary,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eye['label']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    eye['desc']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // 5 fitur lain (bentuk wajah, hidung, bibir, alis, skin tone)
            // sekarang diekstraksi otomatis on-device oleh FaceAnalysisService
            // di LoadingScreen, bukan dipilih manual lagi.
            ElevatedButton(
              onPressed: _selectedEyeType == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoadingScreen(
                            imagePath: widget.imagePath,
                            eyeType: _selectedEyeType!,
                            face: widget.face,
                          ),
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                disabledBackgroundColor: AppTheme.textHint.withOpacity(0.4),
              ),
              child: const Text(
                'LANJUTKAN',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
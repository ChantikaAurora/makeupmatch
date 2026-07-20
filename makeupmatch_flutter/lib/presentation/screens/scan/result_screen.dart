import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isSaved = false;

  // Mengatur URL Gambar -- reuse ApiConstants.baseUrl yang sudah benar
  // untuk kombinasi device+network yang sedang dipakai.
  String get _imageBaseUrl => ApiConstants.imageBaseUrl;

  // Fungsi navigasi BottomNavigationBar yang memperbaiki eror kompilasi sebelumnya
  void _navigateToMainTabs(int index) {
    // Kembali ke halaman utama (Main Tabs / Beranda)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 46),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Berhasil Disimpan!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rekomendasi gaya makeup Anda telah sukses diamankan ke dalam menu Riwayat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('OKEY', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveHistory() async {
    setState(() => _isSaving = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isSaved = true;
        _isSaving = false;
      });
      if (!mounted) return;
      _showSuccessPopup();
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  int _scorePercent(dynamic score) {
    if (score == null) return 0;
    return ((score as num).toDouble() * 100).round();
  }

  String _buildFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';

  final serverUri = Uri.parse(ApiConstants.imageBaseUrl);
  final serverRoot = '${serverUri.scheme}://${serverUri.authority}';

  // Pastikan imageUrl diawali '/'
  final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';

  return '$serverRoot$path';
}

  @override
  Widget build(BuildContext context) {
    final top1 = widget.result['top1'] ?? {};
    final top2 = widget.result['top2'];
    final features = widget.result['face_features'] ?? {}; 

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
          'Hasil Analisis',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rekomendasi Look Anda',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),

            // Profil Fitur Wajah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.face_retouching_natural_rounded, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      const Text(
                        'PROFIL FITUR WAJAH',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeatureChip(label: features['face_shape'] ?? '-', icon: Icons.face_rounded),
                      _FeatureChip(label: features['eye_type'] ?? '-', icon: Icons.remove_red_eye_rounded),
                      _FeatureChip(label: features['nose_shape'] ?? '-', icon: Icons.accessibility_new_rounded),
                      _FeatureChip(label: features['lip_shape'] ?? '-', icon: Icons.bento_rounded),
                      _FeatureChip(label: features['eyebrow_shape'] ?? '-', icon: Icons.brush_rounded),
                      _FeatureChip(label: features['skin_tone'] ?? '-', icon: Icons.palette_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Pilihan Utama
            _buildSectionHeader('PILIHAN UTAMA'),
            const SizedBox(height: 10),
            _RecommendCard(
              nama: top1['nama'] ?? '-',
              score: _scorePercent(top1['score']),
              deskripsi: top1['deskripsi'] ?? '',
              imageUrl: _buildFullImageUrl(top1['image_url']),
              isTop: true,
            ),

            if (top2 != null) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('PILIHAN KEDUA'),
              const SizedBox(height: 10),
              _RecommendCard(
                nama: top2['nama'] ?? '-',
                score: _scorePercent(top2['score']),
                deskripsi: top2['deskripsi'] ?? '',
                imageUrl: _buildFullImageUrl(top2['image_url']), 
                isTop: false,
              ),
            ],
            const SizedBox(height: 36),

            // Tombol Simpan / Reset
            _isSaved
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'BERHASIL DISIMPAN KE RIWAYAT',
                          style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : _isSaving
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : ElevatedButton(
                        onPressed: _saveHistory,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('SIMPAN KE RIWAYAT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppTheme.divider),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('SCAN ULANG WAJAH', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider.withOpacity(0.4), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 1, 
          onTap: _navigateToMainTabs,
          backgroundColor: AppTheme.surface,
          selectedItemColor: const Color(0xFFBC7C81), 
          unselectedItemColor: AppTheme.textSecondary.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.face_outlined), activeIcon: Icon(Icons.face), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.3),
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final String nama;
  final int score;
  final String deskripsi;
  final String imageUrl;
  final bool isTop;

  const _RecommendCard({
    required this.nama,
    required this.score,
    required this.deskripsi,
    required this.imageUrl,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTop ? const Color(0xFFBC7C81) : AppTheme.divider.withOpacity(0.6),
          width: isTop ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBC7C81).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$score% MATCH',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBC7C81)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4F4),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint("Gagal memuat gambar dari URL: $imageUrl");
                          return _buildCardPlaceholder();
                        },
                      )
                    : _buildCardPlaceholder(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppTheme.divider.withOpacity(0.3),
              color: const Color(0xFFBC7C81),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            deskripsi,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPlaceholder() {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 24),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FeatureChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFBC7C81)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
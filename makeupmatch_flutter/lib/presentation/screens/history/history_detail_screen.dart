import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/recommendation_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final RecommendationModel item;

  const HistoryDetailScreen({super.key, required this.item});

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _scorePercent(double score) => (score * 100).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Riwayat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal
            Text(
              _formatDate(item.createdAt),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textHint,
              ),
            ),
            const SizedBox(height: 20),

            // Profil Wajah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accent.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROFIL WAJAH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow('Bentuk Wajah', item.faceShape),
                  _buildFeatureRow('Tipe Mata', item.eyeType),
                  _buildFeatureRow('Skin Tone', item.skinTone),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rekomendasi Utama
            const Text(
              'PILIHAN UTAMA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            _ResultCard(
              nama: item.top1Nama,
              imageUrl: item.fullImageUrl,
              score: _scorePercent(item.top1Score),
              isTop: true,
            ),
            const SizedBox(height: 24),

            // Tombol Scan Lagi
            ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ),
              icon: const Icon(Icons.face_retouching_natural),
              label: const Text('SCAN WAJAH LAGI'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String nama;
  final String? imageUrl;
  final int score;
  final bool isTop;

  const _ResultCard({
    required this.nama,
    this.imageUrl,
    required this.score,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop ? AppTheme.primary : AppTheme.divider,
          width: isTop ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  color: AppTheme.secondary,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.face_retouching_natural,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        )
                      : const Icon(
                          Icons.face_retouching_natural,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                ),
              ),
              Expanded(
                child: Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isTop ? AppTheme.primary : AppTheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$score% MATCH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isTop ? Colors.white : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppTheme.divider,
              color: isTop ? AppTheme.primary : AppTheme.accent,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
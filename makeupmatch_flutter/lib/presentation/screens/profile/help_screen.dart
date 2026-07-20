import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FAQ Data dummy yang relevan dengan fitur MakeupMatch
    final List<Map<String, String>> faqs = [
      {
        'question': 'Bagaimana cara kerja scan rekomendasi?',
        'answer': 'Aplikasi akan menggunakan kamera atau galeri foto Anda untuk menganalisis fitur wajah (bentuk wajah, tipe mata, warna kulit). Model cerdas kami kemudian mencocokkannya dengan database untuk memberikan rekomendasi tipe makeup paling pas.'
      },
      {
        'question': 'Kenapa hasil scan wajah terkadang kurang akurat?',
        'answer': 'Pastikan foto wajah Anda tegak lurus ke depan, memiliki pencahayaan yang terang, dan tidak ada objek yang menghalangi wajah seperti kacamata tebal atau masker agar deteksi berjalan optimal.'
      },
      {
        'question': 'Apakah data riwayat scan saya aman?',
        'answer': 'Tentu saja. Riwayat analisis wajah dan rekomendasi Anda disimpan dengan aman di akun Anda dan tidak akan disebarluaskan ke pihak ketiga.'
      },
      {
        'question': 'Bagaimana cara mengubah nama profil saya?',
        'answer': 'Anda dapat menuju ke menu Profil utama, lalu pilih opsi "Edit Profil" untuk memperbarui nama lengkap Anda.'
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Atas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ada pertanyaan atau kendala?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Cari jawaban cepat melalui daftar pertanyaan yang sering diajukan di bawah ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Judul FAQ
            const Text(
              'PERTANYAAN POPULER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // List FAQ dengan ExpansionTile
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: faqs.length,
              separatorBuilder: (context, index) => const Divider(color: AppTheme.divider),
              itemBuilder: (context, index) {
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    iconColor: AppTheme.primary,
                    collapsedIconColor: AppTheme.textHint,
                    title: Text(
                      faqs[index]['question']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                        child: Text(
                          faqs[index]['answer']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 40),

            // Footer Hubungi Kami
            Center(
              child: Column(
                children: [
                  const Text(
                    'Masih butuh bantuan lain?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Tampilkan snackbar atau dialog kontak
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hubungi Dukungan'),
                          content: const Text('Silakan kirimkan email kendala Anda ke cs.makeupmatch@gmail.com. Tim kami akan segera menanggapi.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            )
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.mail_outline, color: AppTheme.primary, size: 18),
                    label: const Text(
                      'Hubungi Layanan Pengguna',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
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
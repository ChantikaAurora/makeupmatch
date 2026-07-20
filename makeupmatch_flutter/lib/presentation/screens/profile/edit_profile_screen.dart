import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentNama;
  final String currentEmail;

  const EditProfileScreen({
    super.key,
    required this.currentNama,
    required this.currentEmail,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.currentNama);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showStatusDialog({required bool isSuccess, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess ? AppTheme.success : AppTheme.error,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(isSuccess ? 'Berhasil' : 'Gagal', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              if (isSuccess) {
                Navigator.pop(context, _namaController.text.trim()); // Kembali ke halaman profile membawa nama baru
              }
            },
            child: const Text('OK', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final token = await StorageHelper.getToken();
      
      // 1. Jalankan proses update nama
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nama': _namaController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Gagal memperbarui profil');
      }

      // 2. Jalankan proses update password jika kolom diisi
      if (_passwordController.text.isNotEmpty) {
        await AuthService.forgotPassword(
          email: widget.currentEmail,
          newPassword: _passwordController.text,
        );
      }

      // Update data di local storage
      final user = await StorageHelper.getUser();
      await StorageHelper.saveUser(
        id: user['id'] ?? '',
        nama: _namaController.text.trim(),
        email: widget.currentEmail,
      );

      if (!mounted) return;
      _showStatusDialog(isSuccess: true, message: 'Profil Anda telah berhasil diperbarui!');
      
    } catch (e) {
      if (!mounted) return;
      _showStatusDialog(isSuccess: false, message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                
                // ELEMEN AVATAR PREMIUM DENGAN OVERLAY KAMERA
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.divider,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.currentNama.isNotEmpty ? widget.currentNama[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Ubah Foto Profil'),
                            content: const Text('Fitur akses galeri dan kamera siap diintegrasikan menggunakan platform native picker.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // GROUP INFORMASI UTAMA
                _buildSectionHeader('INFORMASI PRIBADI'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nama wajib diisi';
                    if (v.length < 2) return 'Nama minimal 2 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.currentEmail,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email Akun',
                    prefixIcon: const Icon(Icons.mail_outline),
                    suffixIcon: const Icon(Icons.lock_outline, size: 18, color: AppTheme.textHint),
                    filled: true,
                    fillColor: AppTheme.surface,
                  ),
                  style: const TextStyle(color: AppTheme.textHint),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, left: 4.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email tidak dapat diubah', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                  ),
                ),
                
                const SizedBox(height: 32),

                // GROUP AMAN / GANTI PASSWORD
                _buildSectionHeader('KEAMANAN / UBAH PASSWORD'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Password Baru (Kosongkan jika tidak diubah)',
                    prefixIcon: const Icon(Icons.lock_open_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 8) {
                      return 'Password baru minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    prefixIcon: const Icon(Icons.lock_clock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (_passwordController.text.isNotEmpty && v != _passwordController.text) {
                      return 'Konfirmasi password baru tidak cocok';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 40),

                // BUTTON SIMPAN ACTIONS
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}
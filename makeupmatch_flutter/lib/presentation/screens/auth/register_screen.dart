import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  if (!_agreeTerms) {
    // Pop-up jika belum centang persetujuan
    _showErrorDialog('Harap setujui syarat & ketentuan terlebih dahulu.');
    return;
  }
  setState(() => _isLoading = true);
  try {
    await AuthService.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (!mounted) return;
    _showOtpDialog(_emailController.text.trim());
  } catch (e) {
    if (!mounted) return;
    // MENGGUNAKAN POP-UP DIALOG SEBAGAI GANTI SNACKBAR
    _showErrorDialog(e.toString());
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  // Fungsi memunculkan Dialog Pengisian OTP
  void _showOtpDialog(String email) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false, // Wajib diisi, tidak bisa asal klik luar dialog
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kode OTP telah dikirim. Silakan periksa log console backend untuk email: $email'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                hintText: 'Masukkan 4 digit OTP',
                counterText: "",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (otpController.text.length < 4) return;
              try {
                // Kirim OTP untuk aktivasi final di backend
                await AuthService.verifyOtp(email: email, otp: otpController.text.trim());
                if (!mounted) return;
                
                Navigator.pop(context); // Tutup dialog OTP
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registrasi berhasil! Silakan login'),
                    backgroundColor: AppTheme.success,
                  ),
                );
                // Kembalikan ke halaman Login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
                );
              }
            },
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('← Kembali'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header
                const Text(
                  'Buat Akun',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mulai perjalanan makeup-mu',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // Nama Lengkap
                _buildLabel('NAMA LENGKAP'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Nama lengkap Anda',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nama wajib diisi';
                    if (v.length < 2) return 'Nama minimal 2 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email
                _buildLabel('EMAIL'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'nama@email.com',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                _buildLabel('PASSWORD'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Min. 8 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textHint,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Konfirmasi Password
                _buildLabel('KONFIRMASI PASSWORD'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Ulangi password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textHint,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }
                    if (v != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Checkbox Syarat
                Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      onChanged: (v) =>
                          setState(() => _agreeTerms = v ?? false),
                      activeColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Saya menyetujui syarat & ketentuan',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Tombol Register
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('REGISTER'),
                      ),
                const SizedBox(height: 24),

                // Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                    child: const Text(
                      'Sudah punya akun? Masuk',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
  void _showErrorDialog(String message) {
  // Membersihkan teks 'Exception: ' jika terbawa dari throw backend
  final cleanMessage = message.replaceAll('Exception: ', '');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: const [
          Icon(Icons.error_outline, color: AppTheme.error, size: 28),
          SizedBox(width: 10),
          Text(
            'Gagal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        cleanMessage,
        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'OK',
            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
}
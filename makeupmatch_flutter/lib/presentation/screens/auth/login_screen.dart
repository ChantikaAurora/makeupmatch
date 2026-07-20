import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);
  try {
    await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } catch (e) {
    if (!mounted) return;
    _showErrorDialog(e.toString());
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // Header
                const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selamat datang kembali di MakeupMatch',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                // Email
                const Text(
                  'EMAIL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
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
                const Text(
                  'PASSWORD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
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
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: 
                  TextButton(
                    onPressed: () => _showForgotPasswordDialog(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  )
                ),
                const SizedBox(height: 32),
                // Tombol Login
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('SIGN IN'),
                      ),
                const SizedBox(height: 24),
                // Divider ATAU
                Row(
                  children: const [
                    Expanded(child: Divider(color: AppTheme.divider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ATAU',
                        style: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.divider)),
                  ],
                ),
                const SizedBox(height: 24),
                // Google Button
                OutlinedButton.icon(
                  onPressed: _loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('SIGN IN WITH GOOGLE'),
                ),
                const SizedBox(height: 32),
                // Register
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      'Belum punya akun? Daftar sekarang',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Fungsi Google Sign In (Mockup Flow)
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Disini bisa dipasangkan dengan package google_sign_in jika diperlukan di masa depan.
      // Saat ini kita langsung mockup mengirim data email google ke backend
      await AuthService.loginWithGoogle(
        email: 'user.google@gmail.com',
        nama: 'Google User Demo',
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog Alur Lupa Password
  void _showForgotPasswordDialog() {
    final emailResetCtrl = TextEditingController();
    final passResetCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailResetCtrl,
              decoration: const InputDecoration(hintText: 'Masukkan email terdaftar'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passResetCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Masukkan password baru'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (emailResetCtrl.text.isEmpty || passResetCtrl.text.isEmpty) return;
              try {
                await AuthService.forgotPassword(
                  email: emailResetCtrl.text.trim(),
                  newPassword: passResetCtrl.text,
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: AppTheme.success),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
                );
              }
            },
            child: const Text('Simpan'),
          )
        ],
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

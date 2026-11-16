import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  Future<void> _kirimOtp() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final ok = await AuthService().sendOtpEmail(_emailController.text.trim());
    setState(() => _isLoading = false);

    if (ok && mounted) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode OTP sudah dikirim ke Email lu!')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email tidak terdaftar')));
    }
  }

  Future<void> _resetPassword() async {
    if (_otpController.text.isEmpty || _newPassController.text.length < 6) return;
    setState(() => _isLoading = true);
    final ok = await AuthService().resetPasswordWithOtp(_emailController.text.trim(), _otpController.text.trim(), _newPassController.text);
    setState(() => _isLoading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil direset! Silakan login ulang.')));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP salah atau kadaluarsa')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password via Email'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              enabled: !_otpSent,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Aktif Terdaftar', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            if (!_otpSent)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _isLoading ? null : _kirimOtp,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('KIRIM OTP KE EMAIL', style: TextStyle(color: Colors.white)),
              )
            else ...[
              TextField(controller: _otpController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kode OTP', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _newPassController, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN PASSWORD BARU', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';
import '../../pelanggan/screens/dashboard_pelanggan.dart';
import '../../pelanggan/screens/onboarding_ktp_screen.dart';
import '../../penagih/screens/dashboard_penagih.dart';
import '../../pemilik/screens/dashboard_pemilik.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;



  Future<void> _prosesLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi dulu kocak, jangan dikosongin!')));
      return;
    }

    setState(() => _isLoading = true);
    final data = await AuthService().login(_usernameController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);

    if (data != null && mounted) {
      final bool isProfileCompleted = data['is_profile_completed'] ?? false;

      Widget targetScreen;
      if (data['actor'] == 'owner') {
        targetScreen = const DashboardPemilik();
      } else if (data['actor'] == 'penagih') {
        targetScreen = const DashboardPenagih();
      } else {
        targetScreen = isProfileCompleted ? const DashboardPelanggan() : const OnboardingKtpScreen();
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => targetScreen));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login gagal, username atau password salah')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi, size: 75, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text('Yasahaba WiFi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'Hotspot: pakai akun hotspot | PPPoE: nama & sandi default 12345678',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username / Nama / Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: const Text('Lupa Password? (OTP Email)', style: TextStyle(color: Colors.indigo)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _prosesLogin,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('MASUK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
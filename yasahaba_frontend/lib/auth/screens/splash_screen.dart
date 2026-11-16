import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../../pelanggan/screens/dashboard_pelanggan.dart';
import '../../pelanggan/screens/onboarding_ktp_screen.dart';
import '../../penagih/screens/dashboard_penagih.dart';
import '../../pemilik/screens/dashboard_pemilik.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('role');
    final isProfileCompleted = prefs.getBool('is_profile_completed') ?? false;

    if (!mounted) return;

    if (token != null && role != null) {
      if (role == 'owner') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPemilik()));
      } else if (role == 'penagih') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPenagih()));
      } else {
        // Cek apakah pelanggan sudah scan KTP & lengkapi email/no HP
        if (!isProfileCompleted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingKtpScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPelanggan()));
        }
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text('YASAHABA ISP', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
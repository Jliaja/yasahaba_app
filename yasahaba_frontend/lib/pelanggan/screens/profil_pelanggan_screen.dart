import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../auth/screens/login_screen.dart';

class ProfilPelangganScreen extends StatefulWidget {
  const ProfilPelangganScreen({super.key});

  @override
  State<ProfilPelangganScreen> createState() => _ProfilPelangganScreenState();
}

class _ProfilPelangganScreenState extends State<ProfilPelangganScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  Future<void> _gantiPassword() async {
    if (_newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru minimal 6 karakter')));
      return;
    }
    final ok = await AuthService().changePassword(_oldPassController.text, _newPassController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Password berhasil diubah!' : 'Password lama salah')));
      if (ok) {
        _oldPassController.clear();
        _newPassController.clear();
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun & Keamanan'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ganti Password Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: _oldPassController, obscureText: true, decoration: const InputDecoration(labelText: 'Password Lama (Default: 12345678)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _newPassController, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _gantiPassword,
              child: const Text('UPDATE PASSWORD', style: TextStyle(color: Colors.white)),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('KELUAR / LOGOUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
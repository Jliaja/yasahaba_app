import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../auth/screens/login_screen.dart';

class ProfilPemilikScreen extends StatefulWidget {
  const ProfilPemilikScreen({super.key});

  @override
  State<ProfilPemilikScreen> createState() => _ProfilPemilikScreenState();
}

class _ProfilPemilikScreenState extends State<ProfilPemilikScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  Future<void> _gantiPassword() async {
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru minimal 6 karakter')));
      return;
    }
    final ok = await AuthService().changePassword(_oldPassCtrl.text, _newPassCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Password berhasil diubah!' : 'Password lama salah')));
      if (ok) {
        _oldPassCtrl.clear();
        _newPassCtrl.clear();
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
      appBar: AppBar(title: const Text('Akun Pemilik'), backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ganti Password Admin Pusat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: _oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Lama', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade900, padding: const EdgeInsets.symmetric(vertical: 14)),
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
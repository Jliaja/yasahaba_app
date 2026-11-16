import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_pelanggan.dart';
import '../services/pelanggan_service.dart';
import '../../services/api_service.dart';
import '../../auth/screens/login_screen.dart'; // sesuaikan path jika login_screen.dart ada di lib/

class OnboardingKtpScreen extends StatefulWidget {
  const OnboardingKtpScreen({super.key});

  @override
  State<OnboardingKtpScreen> createState() => _OnboardingKtpScreenState();
}

class _OnboardingKtpScreenState extends State<OnboardingKtpScreen> {
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();

  File? _fotoKtp;
  bool _isScanning = false;
  bool _isSubmitting = false;

  Future<void> _konfirmasiBatalKeLogin() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Batalkan Verifikasi?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Data KTP & kontak belum tersimpan. Jika dibatalkan, Anda akan keluar dan kembali ke halaman Login.',
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjut Isi Data'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar ke Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (yakin == true && mounted) {
      // Hapus token & sesi lokal agar tidak nyangkut di splash screen
      try {
        await ApiService().post('/logout');
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _ambilFotoDanScanOcr() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _fotoKtp = File(picked.path);
      _isScanning = true;
    });

    final inputImage = InputImage.fromFilePath(picked.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    String detectedNik = '';
    String detectedNama = '';

    final lines = recognizedText.text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      final cleanDigits = line.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanDigits.length == 16 && detectedNik.isEmpty) {
        detectedNik = cleanDigits;
      }

      if (line.toUpperCase().contains('NAMA')) {
        String inlineName = line.replaceAll(RegExp(r'(?i)nama\s*:?\s*'), '').trim();
        if (inlineName.length > 2) {
          detectedNama = inlineName;
        } else if (i + 1 < lines.length) {
          detectedNama = lines[i + 1].replaceAll(':', '').trim();
        }
      }
    }

    setState(() {
      if (detectedNik.isNotEmpty) _nikController.text = detectedNik;
      if (detectedNama.isNotEmpty) _namaController.text = detectedNama;
      _isScanning = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan selesai! Cek kembali hasil bacaan NIK & Nama sebelum simpan.')),
      );
    }
  }

  Future<void> _simpanDataOnboarding() async {
    if (_fotoKtp == null ||
        _nikController.text.length != 16 ||
        _namaController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        _hpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajib foto KTP, NIK 16 digit, Nama, Email aktif, dan No. HP!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await PelangganService().submitOnboardingKtp(
      nik: _nikController.text.trim(),
      namaKtp: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noHp: _hpController.text.trim(),
      fotoKtp: _fotoKtp!,
    );
    setState(() => _isSubmitting = false);

    if (ok && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_profile_completed', true);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPelanggan()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan data, coba lagi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _konfirmasiBatalKeLogin();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi Data Pelanggan'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: _konfirmasiBatalKeLogin,
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
              label: const Text('Batal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text(
                  'Sebelum masuk ke aplikasi, wajib foto KTP & lengkapi email/no HP untuk validasi pelanggan ISP Yasahaba.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),

              // Bingkai KTP
              GestureDetector(
                onTap: _ambilFotoDanScanOcr,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo, width: 2),
                  ),
                  child: _fotoKtp != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_fotoKtp!, fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card, size: 54, color: Colors.indigo),
                            SizedBox(height: 8),
                            Text('TAP UNTUK FOTO KTP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                            Text('Posisikan KTP pas di dalam bingkai ini', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              if (_isScanning) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
              const SizedBox(height: 16),

              TextField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(labelText: 'NIK (16 Digit - Otomatis dari KTP)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap Sesuai KTP', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Aktif (Untuk Struk & OTP)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor HP / WhatsApp Aktif', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _simpanDataOnboarding,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SIMPAN & MASUK BERANDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _konfirmasiBatalKeLogin,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('BATAL & KEMBALI KE LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
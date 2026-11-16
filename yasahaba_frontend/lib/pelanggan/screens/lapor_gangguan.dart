import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/pelanggan_service.dart';


class LaporGangguanScreen extends StatefulWidget {
  const LaporGangguanScreen({super.key});

  @override
  State<LaporGangguanScreen> createState() => _LaporGangguanScreenState();
}

class _LaporGangguanScreenState extends State<LaporGangguanScreen> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  File? _fotoRouter;
  bool _isSending = false;

  Future<void> _pilihFotoRouter() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (picked != null) {
      setState(() => _fotoRouter = File(picked.path));
    }
  }

  Future<void> _kirimTiket() async {
    if (_judulController.text.isEmpty || _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi judul dan detail kendala dulu')));
      return;
    }

    setState(() => _isSending = true);
final ok = await PelangganService().kirimTiketGangguan(_judulController.text, _deskripsiController.text, _fotoRouter);
    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Tiket gangguan terkirim ke Pemilik!' : 'Gagal mengirim laporan')),
      );
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lapor Gangguan Teknis'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(labelText: 'Kendala (Contoh: Lampu LOS Merah / Mati Total)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Jelaskan detail kondisi wifi di rumah', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: Text(_fotoRouter == null ? 'Foto Lampu Indikator Router (Opsional)' : 'Foto Router Terlampir ✓'),
              onPressed: _pilihFotoRouter,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: _isSending ? null : _kirimTiket,
              child: _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('KIRIM TIKET GANGGUAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
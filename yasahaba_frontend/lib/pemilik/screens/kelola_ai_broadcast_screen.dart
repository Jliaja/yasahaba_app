import 'package:flutter/material.dart';
import '../services/pemilik_service.dart';

class KelolaAiBroadcastScreen extends StatefulWidget {
  const KelolaAiBroadcastScreen({super.key});

  @override
  State<KelolaAiBroadcastScreen> createState() => _KelolaAiBroadcastScreenState();
}

class _KelolaAiBroadcastScreenState extends State<KelolaAiBroadcastScreen> {
  final _knowledgeCtrl = TextEditingController();
  final _broadcastJudulCtrl = TextEditingController();
  final _broadcastPesanCtrl = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKnowledge();
  }

  Future<void> _loadKnowledge() async {
    final text = await PemilikService().getAiKnowledge();
    if (mounted) {
      setState(() {
        _knowledgeCtrl.text = text;
        _isLoading = false;
      });
    }
  }

  Future<void> _simpanKnowledge() async {
    final ok = await PemilikService().saveAiKnowledge(_knowledgeCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Knowledge Base AI berhasil diperbarui!' : 'Gagal menyimpan')),
      );
    }
  }

  Future<void> _kirimBroadcast() async {
    if (_broadcastJudulCtrl.text.isEmpty || _broadcastPesanCtrl.text.isEmpty) return;
    final ok = await PemilikService().kirimBroadcastGangguan(_broadcastJudulCtrl.text, _broadcastPesanCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Broadcast info gangguan massal terkirim ke seluruh pelanggan & dibaca AI!' : 'Gagal kirim broadcast')),
      );
      if (ok) {
        _broadcastJudulCtrl.clear();
        _broadcastPesanCtrl.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Base AI & Broadcast'), backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. EDITOR KNOWLEDGE BASE / SOP GEMINI AI
                const Text('Knowledge Base / SOP Asisten AI (Gemini)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                  'Tulis aturan pembayaran, nomor rekening transfer, promo paket, dan SOP troubleshooting yang akan dijadikan patokan jawaban Gemini AI.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _knowledgeCtrl,
                  maxLines: 7,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: Rekening transfer BCA 123456789 a.n. Yasahaba...'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('SIMPAN KNOWLEDGE BASE AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _simpanKnowledge,
                ),

                const Divider(height: 36, thickness: 2),

                // 2. BROADCAST INFO GANGGUAN MASSAL
                const Text('Broadcast Gangguan Massal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                  'Kirim pengumuman serentak ke seluruh pelanggan (Email & App) serta otomatis diinfokan oleh AI jika ada pelanggan bertanya.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _broadcastJudulCtrl,
                  decoration: const InputDecoration(labelText: 'Judul Pengumuman (misal: Maintenance Kabel FO Utama)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _broadcastPesanCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Isi Pesan & Estimasi Waktu Selesai', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.campaign, color: Colors.white),
                  label: const Text('KIRIM BROADCAST KE SEMUA PELANGGAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _kirimBroadcast,
                ),
              ],
            ),
    );
  }
}
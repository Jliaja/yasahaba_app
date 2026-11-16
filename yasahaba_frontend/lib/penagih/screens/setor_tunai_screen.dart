import 'package:flutter/material.dart';
import '../services/penagih_service.dart';

class SetorTunaiScreen extends StatefulWidget {
  const SetorTunaiScreen({super.key});

  @override
  State<SetorTunaiScreen> createState() => _SetorTunaiScreenState();
}

class _SetorTunaiScreenState extends State<SetorTunaiScreen> {
  bool _isLoading = true;
  int _totalBelumDisetor = 0;
  List<dynamic> _riwayatSetoran = [];
  final _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSetoran();
  }

  Future<void> _loadSetoran() async {
    setState(() => _isLoading = true);
    final res = await PenagihService().getRekapSetoran();
    if (mounted) {
      setState(() {
        _totalBelumDisetor = res?['total_belum_disetor'] ?? 0;
        _riwayatSetoran = res?['riwayat'] ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _ajukanSetoran() async {
    if (_totalBelumDisetor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada uang tunai yang perlu disetor')));
      return;
    }

    final ok = await PenagihService().ajukanSetoran(_catatanController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Pengajuan setoran dikirim! Serahkan uang tunai ke Pemilik untuk divalidasi.' : 'Gagal mengajukan setoran')),
      );
      if (ok) {
        _catatanController.clear();
        _loadSetoran();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dompet & Setor Tunai'), backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Total Akumulasi Tunai Belum Disetor:', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        Text('Rp $_totalBelumDisetor',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _catatanController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan Serah Terima (opsional)',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, padding: const EdgeInsets.symmetric(vertical: 14)),
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text('AJUKAN SETORAN KE PEMILIK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: _ajukanSetoran,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Riwayat Setoran Tunai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_riwayatSetoran.isEmpty)
                  const Text('Belum ada riwayat setoran.', style: TextStyle(color: Colors.grey))
                else
                  ..._riwayatSetoran.map((s) {
                    final isVerified = s['status'] == 'verified';
                    return Card(
                      child: ListTile(
                        leading: Icon(isVerified ? Icons.verified : Icons.pending_actions, color: isVerified ? Colors.green : Colors.orange),
                        title: Text('Rp ${s['nominal']}'),
                        subtitle: Text('Tanggal: ${s['tanggal'] ?? '-'} • ${s['catatan'] ?? ''}'),
                        trailing: Text(
                          isVerified ? 'TERVALIDASI' : 'MENUNGGU ACC',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isVerified ? Colors.green : Colors.orange),
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
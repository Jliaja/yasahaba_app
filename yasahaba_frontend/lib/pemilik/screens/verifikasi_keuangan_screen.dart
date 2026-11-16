import 'package:flutter/material.dart';
import '../services/pemilik_service.dart';

class VerifikasiKeuanganScreen extends StatefulWidget {
  const VerifikasiKeuanganScreen({super.key});

  @override
  State<VerifikasiKeuanganScreen> createState() => _VerifikasiKeuanganScreenState();
}

class _VerifikasiKeuanganScreenState extends State<VerifikasiKeuanganScreen> {
  List<dynamic> _pendingTransfer = [];
  List<dynamic> _pendingSetoran = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final tf = await PemilikService().getAntreanTransferPending();
    final st = await PemilikService().getAntreanSetoranPenagih();
    if (mounted) {
      setState(() {
        _pendingTransfer = tf;
        _pendingSetoran = st;
        _isLoading = false;
      });
    }
  }

  void _lihatFotoBukti(String urlFoto) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(urlFoto, errorBuilder: (_, __, ___) => const Padding(padding: EdgeInsets.all(20), child: Text('Gagal memuat foto bukti'))),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP')),
          ],
        ),
      ),
    );
  }

  Future<void> _prosesTransfer(int tagihanId, String aksi) async {
    String? alasan;
    if (aksi == 'tolak') {
      final alasanCtrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Alasan Penolakan Transfer'),
          content: TextField(controller: alasanCtrl, decoration: const InputDecoration(hintText: 'Misal: Bukti buram / nominal kurang')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('TOLAK')),
          ],
        ),
      );
      if (ok != true) return;
      alasan = alasanCtrl.text;
    }

    final success = await PemilikService().verifikasiTransfer(tagihanId, aksi, alasanTolak: alasan);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Transfer di-${aksi.toUpperCase()} & notifikasi terkirim ke Email!' : 'Gagal memproses')),
      );
      _loadAll();
    }
  }

  Future<void> _validasiSetoran(int setoranId) async {
    final ok = await PemilikService().validasiSetoranPenagih(setoranId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Setoran tunai penagih tervalidasi!' : 'Gagal validasi setoran')),
      );
      _loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi Keuangan'),
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Bukti Transfer (Pending)'),
              Tab(text: 'Setoran Tunai Penagih'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // TAB 1: BUKTI TRANSFER PENDING
                  _pendingTransfer.isEmpty
                      ? const Center(child: Text('Tidak ada antrean bukti transfer.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _pendingTransfer.length,
                          itemBuilder: (context, index) {
                            final t = _pendingTransfer[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${t['nama_pelanggan']} (${t['bulan']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Nominal: Rp ${t['nominal']}'),
                                    const SizedBox(height: 8),
                                    if (t['bukti_url'] != null)
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.image),
                                        label: const Text('Lihat Foto Bukti Transfer'),
                                        onPressed: () => _lihatFotoBukti(t['bukti_url']),
                                      ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            onPressed: () => _prosesTransfer(t['id'], 'acc'),
                                            child: const Text('ACC (LUNAS)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                            onPressed: () => _prosesTransfer(t['id'], 'tolak'),
                                            child: const Text('TOLAK', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                  // TAB 2: SETORAN TUNAI PENAGIH
                  _pendingSetoran.isEmpty
                      ? const Center(child: Text('Tidak ada pengajuan setoran penagih.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _pendingSetoran.length,
                          itemBuilder: (context, index) {
                            final s = _pendingSetoran[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text('${s['nama_penagih']} - Rp ${s['nominal']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Tanggal: ${s['tanggal'] ?? '-'} • ${s['catatan'] ?? ''}'),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                                  onPressed: () => _validasiSetoran(s['id']),
                                  child: const Text('VALIDASI', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }
}
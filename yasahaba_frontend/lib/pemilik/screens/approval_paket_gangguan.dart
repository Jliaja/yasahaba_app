import 'package:flutter/material.dart';
import '../services/pemilik_service.dart';

class ApprovalPaketGangguanScreen extends StatefulWidget {
  const ApprovalPaketGangguanScreen({super.key});

  @override
  State<ApprovalPaketGangguanScreen> createState() => _ApprovalPaketGangguanScreenState();
}

class _ApprovalPaketGangguanScreenState extends State<ApprovalPaketGangguanScreen> {
  List<dynamic> _ubahPaketList = [];
  List<dynamic> _tiketList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final up = await PemilikService().getPengajuanUbahPaket();
    final tk = await PemilikService().getTiketGangguan();
    if (mounted) {
      setState(() {
        _ubahPaketList = up;
        _tiketList = tk;
        _isLoading = false;
      });
    }
  }

  Future<void> _aksiUbahPaket(int id, String aksi) async {
    final ok = await PemilikService().prosesUbahPaket(id, aksi);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Pengajuan paket di-${aksi.toUpperCase()} & Email terkirim!' : 'Gagal memproses')),
      );
      _loadData();
    }
  }

  Future<void> _updateTiket(int id, String status) async {
    final ok = await PemilikService().updateStatusTiket(id, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Status tiket diubah ke ${status.toUpperCase()} (+Email pelanggan)!' : 'Gagal update tiket')),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approval Paket & Gangguan'),
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Pengajuan Ubah Paket'),
              Tab(text: 'Tiket Gangguan'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // TAB 1: PENGAJUAN UBAH PAKET
                  _ubahPaketList.isEmpty
                      ? const Center(child: Text('Tidak ada pengajuan ubah paket.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _ubahPaketList.length,
                          itemBuilder: (context, index) {
                            final u = _ubahPaketList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u['nama_pelanggan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Paket Lama: ${u['paket_lama']} ➔ Baru: ${u['paket_baru']}'),
                                    Text('Diajukan oleh: ${u['diajukan_oleh'] ?? 'Pelanggan'}',
                                        style: const TextStyle(fontSize: 12, color: Colors.indigo)),
                                    if (u['catatan'] != null && u['catatan'].toString().isNotEmpty)
                                      Text('Catatan: ${u['catatan']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            onPressed: () => _aksiUbahPaket(u['id'], 'acc'),
                                            child: const Text('ACC PAKET', style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                            onPressed: () => _aksiUbahPaket(u['id'], 'tolak'),
                                            child: const Text('TOLAK', style: TextStyle(color: Colors.red)),
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

                  // TAB 2: TIKET GANGGUAN
                  _tiketList.isEmpty
                      ? const Center(child: Text('Tidak ada tiket gangguan aktif.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _tiketList.length,
                          itemBuilder: (context, index) {
                            final t = _tiketList[index];
                            final status = (t['status'] ?? 'menunggu').toString().toLowerCase();
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(t['nama_pelanggan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Chip(label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10))),
                                      ],
                                    ),
                                    Text('Kendala: ${t['judul']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(t['deskripsi'] ?? '-'),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        if (status == 'menunggu')
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                              onPressed: () => _updateTiket(t['id'], 'diproses'),
                                              child: const Text('TANDAI DIPROSES', style: TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        if (status != 'selesai') ...[
                                          if (status == 'menunggu') const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                              onPressed: () => _updateTiket(t['id'], 'selesai'),
                                              child: const Text('SELESAI (+EMAIL)', style: TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
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
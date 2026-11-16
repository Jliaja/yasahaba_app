import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/pemilik_service.dart';

class KelolaUserPaketScreen extends StatefulWidget {
  const KelolaUserPaketScreen({super.key});

  @override
  State<KelolaUserPaketScreen> createState() => _KelolaUserPaketScreenState();
}

class _KelolaUserPaketScreenState extends State<KelolaUserPaketScreen> {
  List<dynamic> _paketList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaket();
  }

  Future<void> _loadPaket() async {
    setState(() => _isLoading = true);
    final list = await PemilikService().getDaftarPaket();
    if (mounted) {
      setState(() {
        _paketList = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _exportCsvIsp() async {
    final url = Uri.parse(PemilikService().getExportIspUrl());
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _bukaModalTambahPaket() {
    final namaCtrl = TextEditingController();
    final hargaCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    String serviceType = 'pppoe';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Tambah Paket Layanan Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: serviceType,
                decoration: const InputDecoration(labelText: 'Jenis Service', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'pppoe', child: Text('PPPoE (Router Rumah)')),
                  DropdownMenuItem(value: 'hotspot', child: Text('Hotspot (Voucher/Akun HP)')),
                ],
                onChanged: (val) => setModalState(() => serviceType = val ?? 'pppoe'),
              ),
              const SizedBox(height: 10),
              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Paket (misal: Paket Keluarga 15 Mbps)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: hargaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Bulanan (Rp)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: deskripsiCtrl, decoration: const InputDecoration(labelText: 'Keterangan / Kuota HP', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (namaCtrl.text.isEmpty || hargaCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await PemilikService().tambahPaket(
                    namaPaket: namaCtrl.text,
                    serviceType: serviceType,
                    harga: int.tryParse(hargaCtrl.text) ?? 0,
                    deskripsi: deskripsiCtrl.text,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Paket berhasil ditambahkan!' : 'Gagal menambah paket')));
                    _loadPaket();
                  }
                },
                child: const Text('SIMPAN PAKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bukaModalBuatAkun(String role) {
    final namaCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: role == 'pelanggan' ? '12345678' : '');
    final alamatCtrl = TextEditingController();
    final jatuhTempoCtrl = TextEditingController(text: '10');
    int? selectedPaketId = _paketList.isNotEmpty ? _paketList.first['id'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(role == 'pelanggan' ? 'Buat Akun Pelanggan Baru (PSB)' : 'Buat Akun Penagih Baru',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Panggilan / Lengkap', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                  controller: userCtrl,
                  decoration: InputDecoration(
                    labelText: role == 'pelanggan' ? 'Username Login (Akun Hotspot / Nama)' : 'Username / Email Penagih',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password Awal', border: OutlineInputBorder())),
                if (role == 'pelanggan') ...[
                  const SizedBox(height: 10),
                  TextField(controller: alamatCtrl, decoration: const InputDecoration(labelText: 'Alamat / Blok / RT Rumah', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedPaketId,
                    decoration: const InputDecoration(labelText: 'Pilih Paket Layanan', border: OutlineInputBorder()),
                    items: _paketList.map<DropdownMenuItem<int>>((p) {
                      return DropdownMenuItem<int>(value: p['id'], child: Text('${p['nama_paket']} (${p['service_type']})'));
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedPaketId = val),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: jatuhTempoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tanggal Jatuh Tempo (1-28)', border: OutlineInputBorder()),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    if (namaCtrl.text.isEmpty || userCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                    Navigator.pop(ctx);
                    final ok = await PemilikService().buatAkunUser(
                      role: role,
                      nama: namaCtrl.text,
                      username: userCtrl.text,
                      password: passCtrl.text,
                      alamat: alamatCtrl.text,
                      paketId: selectedPaketId,
                      tglJatuhTempo: int.tryParse(jatuhTempoCtrl.text) ?? 10,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Akun ${role.toUpperCase()} berhasil dibuat!' : 'Gagal membuat akun')),
                      );
                    }
                  },
                  child: const Text('SIMPAN AKUN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master User, Paket & ISP'), backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. EXPORT DATA PELANGGAN (KTP/NIK) KE EXCEL/CSV UNTUK LAPORAN ISP PUSAT
          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(Icons.file_download, color: Colors.green, size: 34),
              title: const Text('Export Data Pelanggan (CSV/Excel)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Unduh rekap NIK, Nama KTP, Email & No. HP untuk laporan ke ISP pusat.'),
              onTap: _exportCsvIsp,
            ),
          ),
          const SizedBox(height: 14),

          // 2. BUAT AKUN PELANGGAN BARU (HASIL DEAL PSB WA) & AKUN PENAGIH
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
                  label: const Text('+ Pelanggan PSB', style: TextStyle(color: Colors.white, fontSize: 12)),
                  onPressed: () => _bukaModalBuatAkun('pelanggan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: const Icon(Icons.badge, color: Colors.white, size: 18),
                  label: const Text('+ Akun Penagih', style: TextStyle(color: Colors.white, fontSize: 12)),
                  onPressed: () => _bukaModalBuatAkun('penagih'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. KELOLA DAFTAR PAKET (PPPoE & HOTSPOT)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Paket Layanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: _bukaModalTambahPaket, icon: const Icon(Icons.add), label: const Text('Tambah Paket')),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ..._paketList.map((p) => Card(
                  child: ListTile(
                    leading: Icon(p['service_type'] == 'hotspot' ? Icons.wifi_tethering : Icons.router, color: Colors.indigo),
                    title: Text('${p['nama_paket']} (${p['service_type'].toString().toUpperCase()})',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rp ${p['harga']}/bulan • ${p['deskripsi'] ?? ''}'),
                  ),
                )),
        ],
      ),
    );
  }
}
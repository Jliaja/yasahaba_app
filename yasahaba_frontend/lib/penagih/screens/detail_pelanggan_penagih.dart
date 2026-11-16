import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/penagih_service.dart';

class DetailPelangganPenagihScreen extends StatefulWidget {
  final dynamic pelanggan;
  const DetailPelangganPenagihScreen({super.key, required this.pelanggan});

  @override
  State<DetailPelangganPenagihScreen> createState() => _DetailPelangganPenagihScreenState();
}

class _DetailPelangganPenagihScreenState extends State<DetailPelangganPenagihScreen> {
  bool _isProcessing = false;

  Future<void> _konfirmasiTerimaTunai() async {
    final tagihanId = widget.pelanggan['tagihan_id'];
    if (tagihanId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Terima Tunai'),
        content: Text(
          'Pastikan sudah menerima uang tunai Rp ${widget.pelanggan['nominal_tagihan']} dari ${widget.pelanggan['nama_lengkap']}.\n\nStatus tagihan akan langsung menjadi LUNAS dan struk dikirim ke Email pelanggan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('YA, TERIMA TUNAI', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    final ok = await PenagihService().terimaTunai(tagihanId);
    setState(() => _isProcessing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Pembayaran tunai dicatat! Struk terkirim ke Email pelanggan.' : 'Gagal memproses pembayaran')),
      );
      if (ok) Navigator.pop(context);
    }
  }

  void _bukaModalDelegasiUbahPaket() async {
    final daftarPaket = await PenagihService().getDaftarPaket();
    if (!mounted) return;

    int? selectedPaketId;
    final catatanCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Bantu Ubah Paket: ${widget.pelanggan['nama_lengkap']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Paket Baru', border: OutlineInputBorder()),
                items: daftarPaket.map<DropdownMenuItem<int>>((p) {
                  return DropdownMenuItem<int>(
                    value: p['id'],
                    child: Text('${p['nama_paket']} - Rp ${p['harga']}'),
                  );
                }).toList(),
                onChanged: (val) => setModalState(() => selectedPaketId = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catatanCtrl,
                decoration: const InputDecoration(labelText: 'Catatan (misal: minta ganti mulai bulan depan)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (selectedPaketId == null) return;
                  Navigator.pop(ctx);
                  final ok = await PenagihService().delegasiUbahPaket(
                    pelangganId: widget.pelanggan['id'],
                    paketBaruId: selectedPaketId!,
                    catatan: catatanCtrl.text,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'Pengajuan ubah paket dikirim ke antrean ACC Pemilik!' : 'Gagal mengirim pengajuan')),
                    );
                  }
                },
                child: const Text('KIRIM PENGAJUAN UBAH PAKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bukaModalDelegasiGangguan() {
    final judulCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    File? fotoRouter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Bantu Lapor Gangguan: ${widget.pelanggan['nama_lengkap']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: judulCtrl,
                decoration: const InputDecoration(labelText: 'Judul Kendala (misal: Kabel Putus / LOS Merah)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deskripsiCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Detail Kondisi di Rumah Pelanggan', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(fotoRouter == null ? 'Foto Router / Kabel (Opsional)' : 'Foto Terlampir ✓'),
                onPressed: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 75);
                  if (picked != null) {
                    setModalState(() => fotoRouter = File(picked.path));
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (judulCtrl.text.isEmpty || deskripsiCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await PenagihService().delegasiTiketGangguan(
                    pelangganId: widget.pelanggan['id'],
                    judul: judulCtrl.text,
                    deskripsi: deskripsiCtrl.text,
                    fotoRouter: fotoRouter,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'Tiket gangguan atas nama pelanggan terkirim ke Pemilik!' : 'Gagal mengirim tiket')),
                    );
                  }
                },
                child: const Text('KIRIM TIKET GANGGUAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pelanggan;
    final status = (p['status_tagihan'] ?? 'belum_lunas').toString().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail & Layanan Lapangan'), backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // 1. PROFIL & PAKET PELANGGAN
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['nama_lengkap'] ?? '-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Alamat: ${p['alamat'] ?? '-'}'),
                  Text('No. HP: ${p['no_hp'] ?? '-'}'),
                  const Divider(height: 20),
                  Text('Layanan: ${(p['service_type'] ?? 'pppoe').toString().toUpperCase()}'),
                  Text('Paket Aktif: ${p['nama_paket'] ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. AKSI PENAGIHAN BERDASARKAN STATUS
          const Text('Status Penagihan Bulan Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          if (status == 'belum_lunas')
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Tagihan: Rp ${p['nominal_tagihan'] ?? 0} (BELUM LUNAS)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.payments, color: Colors.white),
                      label: _isProcessing
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('TERIMA TUNAI (LUNASKAN)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: _isProcessing ? null : _konfirmasiTerimaTunai,
                    ),
                  ],
                ),
              ),
            )
          else if (status == 'pending')
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber)),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Status PENDING: Pelanggan sudah upload bukti transfer dan sedang menunggu ACC Pemilik. Lewati penagihan tunai.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Tagihan bulan ini sudah LUNAS.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // 3. DELEGASI CS LAPANGAN (BANTU PELANGGAN GAPTEK)
          const Text('Bantu Layanan Pelanggan (CS Lapangan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.upgrade, color: Colors.orange),
            label: const Text('Bantu Ajukan Upgrade / Ubah Paket'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _bukaModalDelegasiUbahPaket,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.build_circle, color: Colors.redAccent),
            label: const Text('Bantu Input Tiket Gangguan Fisik'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _bukaModalDelegasiGangguan,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/pelanggan_service.dart';

class UbahPaketScreen extends StatefulWidget {
  const UbahPaketScreen({super.key});

  @override
  State<UbahPaketScreen> createState() => _UbahPaketScreenState();
}

class _UbahPaketScreenState extends State<UbahPaketScreen> {
  List<dynamic> _paketList = [];
  int? _selectedPaketId;
  final _catatanController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaket();
  }

  Future<void> _loadPaket() async {
    final list = await PelangganService().getDaftarPaket();
    setState(() {
      _paketList = list;
      _isLoading = false;
    });
  }

  Future<void> _submitUbahPaket() async {
    if (_selectedPaketId == null) return;
    final ok = await PelangganService().ajukanUbahPaket(_selectedPaketId!, _catatanController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Pengajuan ubah paket terkirim! Menunggu ACC Pemilik.' : 'Gagal mengirim pengajuan')),
      );
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade / Ubah Paket'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Pilih paket baru (PPPoE atau Hotspot):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _paketList.length,
                      itemBuilder: (context, index) {
                        final p = _paketList[index];
                        return RadioListTile<int>(
                          value: p['id'],
                          groupValue: _selectedPaketId,
                          onChanged: (val) => setState(() => _selectedPaketId = val),
                          title: Text('${p['nama_paket']} (${p['service_type'].toString().toUpperCase()})'),
                          subtitle: Text('Rp ${p['harga']}/bulan • ${p['deskripsi'] ?? ''}'),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _catatanController,
                    decoration: const InputDecoration(labelText: 'Catatan tambahan (opsional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _submitUbahPaket,
                    child: const Text('AJUKAN PERUBAHAN PAKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }
}
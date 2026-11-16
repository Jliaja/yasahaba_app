import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/pelanggan_service.dart';

class RiwayatTagihanScreen extends StatefulWidget {
  const RiwayatTagihanScreen({super.key});

  @override
  State<RiwayatTagihanScreen> createState() => _RiwayatTagihanScreenState();
}

class _RiwayatTagihanScreenState extends State<RiwayatTagihanScreen> {
  List<dynamic> _tagihanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTagihan();
  }

  Future<void> _fetchTagihan() async {
    setState(() => _isLoading = true);
    final list = await PelangganService().getTagihan();
    setState(() {
      _tagihanList = list;
      _isLoading = false;
    });
  }

  Future<void> _prosesUploadBuktiTf(int tagihanId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final ok = await PelangganService().uploadBuktiTransfer(tagihanId, File(picked.path));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Bukti transfer terkirim! Status berubah PENDING menunggu ACC Pemilik.'
              : 'Gagal upload bukti transfer'),
        ),
      );
      _fetchTagihan();
    }
  }

  void _lihatStrukDigital(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Struk Pembayaran Lunas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No. Invoice: #${item['id']}'),
            Text('Periode: ${item['bulan']}'),
            Text('Nominal: Rp ${item['nominal']}'),
            Text('Metode: ${item['metode_bayar'] ?? '-'}'),
            Text('Tgl Lunas: ${item['tgl_lunas'] ?? '-'}'),
            const Divider(),
            const Text('Salinan resmi struk ini juga telah dikirim ke Email aktif Anda.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tagihan & Pembayaran'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tagihanList.length,
              itemBuilder: (context, index) {
                final item = _tagihanList[index];
                final status = (item['status'] ?? 'belum_lunas').toString().toLowerCase();

                Color badgeColor = Colors.red;
                String badgeText = 'BELUM LUNAS';
                if (status == 'pending') {
                  badgeColor = Colors.orange;
                  badgeText = 'PENDING (MENUNGGU ACC)';
                } else if (status == 'lunas') {
                  badgeColor = Colors.green;
                  badgeText = 'LUNAS';
                }

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
                            Text('Periode: ${item['bulan']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                              child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Total Tagihan: Rp ${item['nominal']}', style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 10),
                        if (status == 'belum_lunas')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Transfer ke BCA 123456789 a.n. Pemilik Yasahaba atau bayar tunai saat penagih datang.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.upload_file, color: Colors.white),
                                label: const Text('Upload Bukti Transfer', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                                onPressed: () => _prosesUploadBuktiTf(item['id']),
                              ),
                            ],
                          )
                        else if (status == 'pending')
                          const Text('Bukti transfer sedang dicek pemilik. Penagih tidak akan menagih tunai selama status Pending.',
                              style: TextStyle(fontSize: 12, color: Colors.orange))
                        else if (status == 'lunas')
                          OutlinedButton.icon(
                            icon: const Icon(Icons.receipt),
                            label: const Text('Lihat Struk Digital Lunas'),
                            onPressed: () => _lihatStrukDigital(item),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
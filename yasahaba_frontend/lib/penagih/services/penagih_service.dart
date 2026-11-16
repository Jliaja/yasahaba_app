import 'dart:convert';
import 'dart:io';
import '../../services/api_service.dart';

class PenagihService {
  final ApiService _api = ApiService();

  // 1. Dashboard & Daftar Pelanggan / Tagihan Wilayah
  Future<JsonMap?> getDashboard() async {
    final res = await _api.get('/penagih/dashboard');
    if (res.statusCode == 200) return jsonDecode(res.body) as JsonMap;
    return null;
  }

  // 2. Konfirmasi Terima Tunai di Rumah Pelanggan
  Future<bool> terimaTunai(int tagihanId) async {
    final res = await _api.post('/penagih/tagihan/$tagihanId/terima-tunai');
    return res.statusCode == 200;
  }

  // 3. Ambil Daftar Paket (untuk Delegasi Ubah Paket)
  Future<List<dynamic>> getDaftarPaket() async {
    final res = await _api.get('/penagih/paket');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  // 4. Delegasi Ajukan Ubah Paket atas nama Pelanggan Gaptek
  Future<bool> delegasiUbahPaket({
    required int pelangganId,
    required int paketBaruId,
    required String catatan,
  }) async {
    final res = await _api.post('/penagih/delegasi/ubah-paket', body: {
      'pelanggan_id': pelangganId,
      'paket_baru_id': paketBaruId,
      'catatan': catatan,
    });
    return res.statusCode == 200;
  }

  // 5. Delegasi Input Tiket Gangguan atas nama Pelanggan Gaptek
  Future<bool> delegasiTiketGangguan({
    required int pelangganId,
    required String judul,
    required String deskripsi,
    File? fotoRouter,
  }) async {
    final res = await _api.postMultipart(
      '/penagih/delegasi/tiket-gangguan',
      fields: {
        'pelanggan_id': pelangganId.toString(),
        'judul': judul,
        'deskripsi': deskripsi,
      },
      files: fotoRouter != null ? {'foto_router': fotoRouter} : null,
    );
    return res.statusCode == 200;
  }

  // 6. Data Dompet Tunai & Riwayat Setoran ke Pemilik
  Future<JsonMap?> getRekapSetoran() async {
    final res = await _api.get('/penagih/setoran');
    if (res.statusCode == 200) return jsonDecode(res.body) as JsonMap;
    return null;
  }

  // 7. Ajukan Setor Uang Tunai ke Pemilik
  Future<bool> ajukanSetoran(String catatan) async {
    final res = await _api.post('/penagih/setoran/ajukan', body: {
      'catatan': catatan,
    });
    return res.statusCode == 200;
  }
}
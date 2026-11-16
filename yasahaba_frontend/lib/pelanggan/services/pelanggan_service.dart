import 'dart:convert';
import 'dart:io';
import '../../services/api_service.dart';

class PelangganService {
  final ApiService _api = ApiService();

  Future<bool> submitOnboardingKtp({
    required String nik,
    required String namaKtp,
    required String email,
    required String noHp,
    required File fotoKtp,
  }) async {
    final res = await _api.postMultipart(
      '/pelanggan/onboarding-ktp',
      fields: {
        'nik': nik,
        'nama_lengkap': namaKtp,
        'email': email,
        'no_hp': noHp,
      },
      files: {'foto_ktp': fotoKtp},
    );
    return res.statusCode == 200;
  }

  Future<JsonMap?> getDashboard() async {
    final res = await _api.get('/pelanggan/dashboard');
    if (res.statusCode == 200) return jsonDecode(res.body) as JsonMap;
    return null;
  }

  Future<bool> resetHotspotSession() async {
    final res = await _api.post('/pelanggan/hotspot/reset-session');
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getTagihan() async {
    final res = await _api.get('/pelanggan/tagihan');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  Future<bool> uploadBuktiTransfer(int tagihanId, File fotoBukti) async {
    final res = await _api.postMultipart(
      '/pelanggan/tagihan/$tagihanId/upload-bukti',
      fields: {},
      files: {'bukti_transfer': fotoBukti},
    );
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getDaftarPaket() async {
    final res = await _api.get('/pelanggan/paket');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  Future<bool> ajukanUbahPaket(int paketBaruId, String catatan) async {
    final res = await _api.post('/pelanggan/ubah-paket', body: {
      'paket_baru_id': paketBaruId,
      'catatan': catatan,
    });
    return res.statusCode == 200;
  }

  Future<String> askGeminiAi(String pesan) async {
    final res = await _api.post('/pelanggan/ask-ai', body: {'message': pesan});
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['reply'] ?? 'Maaf, AI sedang tidak merespon.';
    }
    return 'Gagal terhubung ke asisten AI Yasahaba.';
  }

  Future<bool> kirimTiketGangguan(String judul, String deskripsi, File? fotoRouter) async {
    final res = await _api.postMultipart(
      '/pelanggan/tiket-gangguan',
      fields: {'judul': judul, 'deskripsi': deskripsi},
      files: fotoRouter != null ? {'foto_router': fotoRouter} : null,
    );
    return res.statusCode == 200;
  }
}
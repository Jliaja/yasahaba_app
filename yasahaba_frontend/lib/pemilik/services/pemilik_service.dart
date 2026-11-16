import 'dart:convert';
import '../../services/api_service.dart';

class PemilikService {
  final ApiService _api = ApiService();

  // 1. DASHBOARD ANALITIK & KAS
  Future<JsonMap?> getDashboard() async {
    final res = await _api.get('/owner/dashboard');
    if (res.statusCode == 200) return jsonDecode(res.body) as JsonMap;
    return null;
  }

  // 2. MASTER PAKET, AKUN USER (PELANGGAN/PENAGIH) & EXPORT CSV ISP
  Future<List<dynamic>> getDaftarPaket() async {
    final res = await _api.get('/owner/paket');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  Future<bool> tambahPaket({
    required String namaPaket,
    required String serviceType, // 'pppoe' atau 'hotspot'
    required int harga,
    required String deskripsi,
  }) async {
    final res = await _api.post('/owner/paket', body: {
      'nama_paket': namaPaket,
      'service_type': serviceType,
      'harga': harga,
      'deskripsi': deskripsi,
    });
    return res.statusCode == 200;
  }

  Future<bool> buatAkunUser({
    required String role, // 'pelanggan' atau 'penagih'
    required String nama,
    required String username,
    required String password,
    String? alamat,
    int? paketId,
    int? tglJatuhTempo,
  }) async {
    final res = await _api.post('/owner/users', body: {
      'role': role,
      'nama': nama,
      'username': username,
      'password': password,
      'alamat': alamat,
      'paket_id': paketId,
      'tgl_jatuh_tempo': tglJatuhTempo,
    });
    return res.statusCode == 200;
  }

  // Mengembalikan URL download file Excel/CSV laporan data KTP/NIK pelanggan ke ISP
  String getExportIspUrl() {
    return '${ApiService.baseUrl}/owner/export-pelanggan-isp';
  }

  // 3. MANAJEMEN TAGIHAN, VERIFIKASI TRANSFER & VALIDASI SETORAN
  Future<bool> generateTagihanBulanan(String bulan) async {
    final res = await _api.post('/owner/tagihan/generate', body: {'bulan': bulan});
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getAntreanTransferPending() async {
    final res = await _api.get('/owner/tagihan/pending');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  Future<bool> verifikasiTransfer(int tagihanId, String aksi, {String? alasanTolak}) async {
    // aksi: 'acc' atau 'tolak'
    final res = await _api.post('/owner/tagihan/$tagihanId/verifikasi', body: {
      'aksi': aksi,
      'alasan': alasanTolak,
    });
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getAntreanSetoranPenagih() async {
    final res = await _api.get('/owner/setoran/pending');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  Future<bool> validasiSetoranPenagih(int setoranId) async {
    final res = await _api.post('/owner/setoran/$setoranId/validasi');
    return res.statusCode == 200;
  }

  // 4. APPROVAL UBAH PAKET & TIKET GANGGUAN
  Future<List<dynamic>> getPengajuanUbahPaket() async {
    final res = await _api.get('/owner/ubah-paket');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  Future<bool> prosesUbahPaket(int pengajuanId, String aksi) async {
    // aksi: 'acc' atau 'tolak'
    final res = await _api.post('/owner/ubah-paket/$pengajuanId/proses', body: {'aksi': aksi});
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getTiketGangguan() async {
    final res = await _api.get('/owner/tiket-gangguan');
    if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
    return [];
  }

  Future<bool> updateStatusTiket(int tiketId, String status) async {
    // status: 'diproses' atau 'selesai'
    final res = await _api.post('/owner/tiket-gangguan/$tiketId/status', body: {'status': status});
    return res.statusCode == 200;
  }

  // 5. KNOWLEDGE BASE GEMINI AI & BROADCAST GANGGUAN MASSAL
  Future<String> getAiKnowledge() async {
    final res = await _api.get('/owner/ai-knowledge');
    if (res.statusCode == 200) return jsonDecode(res.body)['content'] ?? '';
    return '';
  }

  Future<bool> saveAiKnowledge(String content) async {
    final res = await _api.post('/owner/ai-knowledge', body: {'content': content});
    return res.statusCode == 200;
  }

  Future<bool> kirimBroadcastGangguan(String judul, String pesan) async {
    final res = await _api.post('/owner/broadcast', body: {'judul': judul, 'pesan': pesan});
    return res.statusCode == 200;
  }
}
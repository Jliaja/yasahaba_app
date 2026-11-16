import 'package:flutter/material.dart';
import '../services/penagih_service.dart';
import 'detail_pelanggan_penagih.dart';
import 'setor_tunai_screen.dart';
import 'profil_penagih_screen.dart';

class DashboardPenagih extends StatefulWidget {
  const DashboardPenagih({super.key});

  @override
  State<DashboardPenagih> createState() => _DashboardPenagihState();
}

class _DashboardPenagihState extends State<DashboardPenagih> {
  bool _isLoading = true;
  int _uangDipegang = 0;
  List<dynamic> _semuaPelanggan = [];
  String _filterStatus = 'semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatRp(dynamic angka) {
    final val = int.tryParse(angka.toString().split('.').first) ?? 0;
    final str = val.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return 'Rp $buf';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await PenagihService().getDashboard();
    if (mounted) {
      setState(() {
        _uangDipegang = int.tryParse((res?['uang_dipegang'] ?? 0).toString().split('.').first) ?? 0;
        _semuaPelanggan = res?['pelanggan'] ?? [];
        _isLoading = false;
      });
    }
  }

  int _countByStatus(String st) {
    if (st == 'semua') return _semuaPelanggan.length;
    return _semuaPelanggan.where((e) => (e['status_tagihan'] ?? 'belum_lunas').toString().toLowerCase() == st).length;
  }

  List<dynamic> get _filteredList {
    return _semuaPelanggan.where((item) {
      final status = (item['status_tagihan'] ?? 'belum_lunas').toString().toLowerCase();
      final nama = (item['nama_lengkap'] ?? '').toString().toLowerCase();
      final alamat = (item['alamat'] ?? '').toString().toLowerCase();

      final matchStatus = _filterStatus == 'semua' || status == _filterStatus;
      final matchSearch = _searchQuery.isEmpty || nama.contains(_searchQuery) || alamat.contains(_searchQuery);
      return matchStatus && matchSearch;
    }).toList();
  }

  void _bukaRingkasanTugas() {
    final belumLunas = _countByStatus('belum_lunas');
    final pendingTf = _countByStatus('pending');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            const Text('Info Tugas Lapangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFEE2E2), child: Icon(Icons.home_work_rounded, color: Colors.red)),
              title: Text('$belumLunas Pelanggan Belum Lunas', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Tap untuk filter daftar rumah yang siap ditagih'),
              onTap: () {
                setState(() => _filterStatus = 'belum_lunas');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFEF3C7), child: Icon(Icons.hourglass_bottom_rounded, color: Colors.orange)),
              title: Text('$pendingTf Pelanggan Sedang Pending Transfer', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Lewati penagihan tunai karena sedang menunggu ACC Pemilik'),
              onTap: () {
                setState(() => _filterStatus = 'pending');
                Navigator.pop(ctx);
              },
            ),
            if (_uangDipegang > 0)
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFDCFCE7), child: Icon(Icons.account_balance_wallet_rounded, color: Colors.green)),
                title: Text('Uang Tunai Dipegang: ${_formatRp(_uangDipegang)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Segera ajukan setoran ke Pemilik setelah selesai berkeliling'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SetorTunaiScreen())).then((_) => _loadData());
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final belumLunasCount = _countByStatus('belum_lunas');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // HEADER MODERN KOLEKTOR
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7C2D12), Color(0xFFC2410C), Color(0xFFEA580C)],
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('KOLEKTOR LAPANGAN', style: TextStyle(color: Colors.orange.shade200, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                                const SizedBox(height: 2),
                                const Text('Yasahaba Penagih', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                      child: IconButton(
                                        icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                                        onPressed: _bukaRingkasanTugas,
                                      ),
                                    ),
                                    if (belumLunasCount > 0)
                                      Positioned(
                                        right: 6,
                                        top: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                                          child: Text('$belumLunasCount', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                  child: IconButton(
                                    icon: const Icon(Icons.person_rounded, color: Colors.white),
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilPenagihScreen())),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // KARTU DOMPET TUNAI PENAGIH
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Uang Tunai Dipegang', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(_formatRp(_uangDipegang), style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF9A3412),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                                icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                                label: const Text('Setor Tunai', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const SetorTunaiScreen()));
                                  _loadData();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SEARCH BAR MODERN
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari nama pelanggan, blok, atau alamat...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    ),
                  ),

                  // FILTER CHIPS DENGAN ANGKA REALTIME
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _filterChip('Semua (${_countByStatus('semua')})', 'semua'),
                        const SizedBox(width: 8),
                        _filterChip('Belum Lunas (${_countByStatus('belum_lunas')})', 'belum_lunas'),
                        const SizedBox(width: 8),
                        _filterChip('Pending (${_countByStatus('pending')})', 'pending'),
                        const SizedBox(width: 8),
                        _filterChip('Lunas (${_countByStatus('lunas')})', 'lunas'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // LIST PELANGGAN
                  Expanded(
                    child: _filteredList.isEmpty
                        ? Center(child: Text('Tidak ada data pelanggan pada filter ini.', style: TextStyle(color: Colors.grey.shade500)))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              final p = _filteredList[index];
                              final nama = (p['nama_lengkap'] ?? '-').toString();
                              final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
                              final status = (p['status_tagihan'] ?? 'belum_lunas').toString().toLowerCase();

                              Color badgeBg = const Color(0xFFFEE2E2);
                              Color badgeText = const Color(0xFFDC2626);
                              String badgeLabel = 'BELUM LUNAS';

                              if (status == 'pending') {
                                badgeBg = const Color(0xFFFEF3C7);
                                badgeText = const Color(0xFFD97706);
                                badgeLabel = 'PENDING TF';
                              } else if (status == 'lunas') {
                                badgeBg = const Color(0xFFDCFCE7);
                                badgeText = const Color(0xFF16A34A);
                                badgeLabel = 'LUNAS';
                              }

                              return InkWell(
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPelangganPenagihScreen(pelanggan: p)));
                                  _loadData();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(0xFFFFEDD5),
                                        child: Text(inisial, style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                            const SizedBox(height: 2),
                                            Text('${p['nama_paket'] ?? '-'} • ${p['alamat'] ?? '-'}',
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 4),
                                            Text(_formatRp(p['nominal_tagihan'] ?? 0),
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF1E293B))),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                                            child: Text(badgeLabel, style: TextStyle(color: badgeText, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(height: 8),
                                          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFEA580C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? const Color(0xFFEA580C) : Colors.grey.shade300),
      ),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12),
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }
}
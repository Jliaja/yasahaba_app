import 'package:flutter/material.dart';
import '../services/pemilik_service.dart';
import 'kelola_user_paket_screen.dart';
import 'verifikasi_keuangan_screen.dart';
import 'approval_paket_gangguan.dart';
import 'kelola_ai_broadcast_screen.dart';
import 'profil_pemilik_screen.dart';
import '../../services/api_service.dart';

class DashboardPemilik extends StatefulWidget {
  const DashboardPemilik({super.key});

  @override
  State<DashboardPemilik> createState() => _DashboardPemilikState();
}

class _DashboardPemilikState extends State<DashboardPemilik> {
  bool _isLoading = true;
  JsonMap _stats = {};
  int _pendingTransfer = 0;
  int _pendingSetoran = 0;
  int _pendingUbahPaket = 0;
  int _pendingTiket = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
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

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final svc = PemilikService();
    final results = await Future.wait([
      svc.getDashboard(),
      svc.getAntreanTransferPending(),
      svc.getAntreanSetoranPenagih(),
      svc.getPengajuanUbahPaket(),
      svc.getTiketGangguan(),
    ]);

    if (mounted) {
      setState(() {
        _stats = (results[0] as JsonMap?) ?? {};
        _pendingTransfer = (results[1] as List).length;
        _pendingSetoran = (results[2] as List).length;
        _pendingUbahPaket = (results[3] as List).length;
        _pendingTiket = (results[4] as List)
            .where((t) => (t['status'] ?? '').toString().toLowerCase() != 'selesai')
            .length;
        _isLoading = false;
      });
    }
  }

  int get _totalNotif => _pendingTransfer + _pendingSetoran + _pendingUbahPaket + _pendingTiket;

  void _bukaPusatNotifikasi() {
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pusat Notifikasi & Antrean', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Text('$_totalNotif Butuh Aksi', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_totalNotif == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Semua aman! Tidak ada antrean yang tertunda.', style: TextStyle(color: Colors.grey))),
              )
            else ...[
              if (_pendingTransfer > 0)
                _notifTile(
                  Icons.receipt_long_rounded,
                  Colors.blue,
                  '$_pendingTransfer Bukti Transfer Masuk',
                  'Menunggu pengecekan mutasi & klik ACC',
                  () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiKeuanganScreen())).then((_) => _loadDashboard());
                  },
                ),
              if (_pendingSetoran > 0)
                _notifTile(
                  Icons.payments_rounded,
                  Colors.green,
                  '$_pendingSetoran Setoran Tunai Penagih',
                  'Validasi uang tunai dari kolektor lapangan',
                  () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiKeuanganScreen())).then((_) => _loadDashboard());
                  },
                ),
              if (_pendingUbahPaket > 0)
                _notifTile(
                  Icons.swap_vert_circle_rounded,
                  Colors.orange,
                  '$_pendingUbahPaket Pengajuan Ubah Paket',
                  'Permintaan upgrade/ganti paket pelanggan',
                  () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalPaketGangguanScreen())).then((_) => _loadDashboard());
                  },
                ),
              if (_pendingTiket > 0)
                _notifTile(
                  Icons.warning_amber_rounded,
                  Colors.red,
                  '$_pendingTiket Tiket Gangguan Aktif',
                  'Keluhan jaringan menunggu penanganan teknis',
                  () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalPaketGangguanScreen())).then((_) => _loadDashboard());
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _notifTile(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: color),
        onTap: onTap,
      ),
    );
  }

  Future<void> _dialogGenerateTagihan() async {
    final bulanCtrl = TextEditingController(text: 'November 2026');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terbitkan Tagihan Bulanan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sistem akan membuat invoice (BELUM LUNAS) untuk seluruh pelanggan aktif dan mengirim email tagihan otomatis.', style: TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 14),
            TextField(
              controller: bulanCtrl,
              decoration: InputDecoration(
                labelText: 'Periode Bulan',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1B4B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Terbitkan Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && bulanCtrl.text.isNotEmpty) {
      final ok = await PemilikService().generateTagihanBulanan(bulanCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
            content: Text(ok ? 'Tagihan bulanan berhasil diterbitkan & terkirim ke email!' : 'Gagal menerbitkan tagihan'),
          ),
        );
        _loadDashboard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifKeuangan = _pendingTransfer + _pendingSetoran;
    final notifOperasional = _pendingUbahPaket + _pendingTiket;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: CustomScrollView(
                slivers: [
                  // HEADER MODERN + HERO KEUANGAN
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 52, 20, 26),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TOP BAR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('YASAHABA NETWORK', style: TextStyle(color: Colors.blue.shade200, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                                  const SizedBox(height: 2),
                                  const Text('Pusat Kendali Owner', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  // TOMBOL LONCENG NOTIFIKASI
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                                        child: IconButton(
                                          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                                          onPressed: _bukaPusatNotifikasi,
                                        ),
                                      ),
                                      if (_totalNotif > 0)
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                            child: Text('$_totalNotif', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                                    child: IconButton(
                                      icon: const Icon(Icons.person_rounded, color: Colors.white),
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilPemilikScreen())),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // KARTU GLASSMORPHISM PEMASUKAN
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Pemasukan Lunas', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                      child: const Text('Bulan Ini', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatRp(_stats['total_pemasukan'] ?? 0),
                                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _miniIncomeBadge(Icons.account_balance_rounded, 'Via Transfer', _formatRp(_stats['pemasukan_transfer'] ?? 0)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _miniIncomeBadge(Icons.payments_rounded, 'Tunai Penagih', _formatRp(_stats['pemasukan_tunai'] ?? 0)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BODY CONTENT
                  SliverPadding(
                    padding: const EdgeInsets.all(18),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // BANNER ALERT JIKA ADA YANG PERLU ACC
                        if (_totalNotif > 0)
                          GestureDetector(
                            onTap: _bukaPusatNotifikasi,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.amber.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.notifications_active_rounded, color: Colors.amber.shade800),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Ada $_totalNotif antrean penting menunggu konfirmasi Anda.',
                                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                  Text('Lihat', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),

                        // 3 KARTU RINGKASAN ANGKA
                        Row(
                          children: [
                            _kpiCard('Pelanggan', '${_stats['total_pelanggan'] ?? 0}', Icons.wifi_rounded, const Color(0xFF10B981)),
                            const SizedBox(width: 10),
                            _kpiCard('Belum Lunas', '${_stats['belum_lunas'] ?? 0}', Icons.schedule_rounded, const Color(0xFFEF4444)),
                            const SizedBox(width: 10),
                            _kpiCard('Tf Pending', '${_stats['transfer_pending'] ?? 0}', Icons.hourglass_top_rounded, const Color(0xFFF59E0B)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // TOMBOL AKSI UTAMA: GENERATE TAGIHAN
                        InkWell(
                          onTap: _dialogGenerateTagihan,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF059669)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: const Color(0xFF059669).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.send_rounded, color: Colors.white),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Terbitkan Tagihan Bulanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text('Buat invoice serentak & kirim notifikasi email', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // GRID MENU KENDALI
                        const Text('Kendali Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                          children: [
                            _modernMenuCard(
                              icon: Icons.verified_user_rounded,
                              title: 'ACC Transfer &\nSetoran Tunai',
                              subtitle: 'Verifikasi masuk',
                              color: const Color(0xFF059669),
                              badgeCount: notifKeuangan,
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiKeuanganScreen()));
                                _loadDashboard();
                              },
                            ),
                            _modernMenuCard(
                              icon: Icons.assignment_turned_in_rounded,
                              title: 'Approval Paket &\nTiket Gangguan',
                              subtitle: 'Request & komplain',
                              color: const Color(0xFFEA580C),
                              badgeCount: notifOperasional,
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalPaketGangguanScreen()));
                                _loadDashboard();
                              },
                            ),
                            _modernMenuCard(
                              icon: Icons.people_alt_rounded,
                              title: 'User, Paket &\nExport CSV ISP',
                              subtitle: 'Master data KTP',
                              color: const Color(0xFF2563EB),
                              badgeCount: 0,
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaUserPaketScreen()));
                                _loadDashboard();
                              },
                            ),
                            _modernMenuCard(
                              icon: Icons.smart_toy_rounded,
                              title: 'Knowledge AI &\nBroadcast Info',
                              subtitle: 'SOP & gangguan massal',
                              color: const Color(0xFF7C3AED),
                              badgeCount: 0,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaAiBroadcastScreen())),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _miniIncomeBadge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _modernMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: badgeCount > 0 ? color.withOpacity(0.5) : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                    child: Text('$badgeCount Baru', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A), height: 1.2)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
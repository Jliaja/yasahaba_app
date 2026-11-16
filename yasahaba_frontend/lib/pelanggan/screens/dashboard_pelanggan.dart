import 'package:flutter/material.dart';
import '../services/pelanggan_service.dart';
import 'riwayat_tagihan.dart';
import 'ubah_paket_screen.dart';
import 'chat_ai_screen.dart';
import 'lapor_gangguan.dart';
import 'profil_pelanggan_screen.dart';

class DashboardPelanggan extends StatefulWidget {
  const DashboardPelanggan({super.key});

  @override
  State<DashboardPelanggan> createState() => _DashboardPelangganState();
}

class _DashboardPelangganState extends State<DashboardPelanggan> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _sudahTampilPopup = false;

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
    final res = await PelangganService().getDashboard();
    if (mounted) {
      setState(() {
        _data = res;
        _isLoading = false;
      });

      final tagihan = res?['tagihan_bulan_ini'];
      final user = res?['user'] ?? {};
      if (!_sudahTampilPopup && tagihan != null) {
        final st = (tagihan['status'] ?? '').toString().toLowerCase();
        if (st == 'belum_lunas' || st == 'belum_dibayar') {
          _sudahTampilPopup = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tampilkanDialogPengingatTagihan(tagihan, user['tgl_jatuh_tempo'] ?? 10);
          });
        }
      }
    }
  }

  void _tampilkanDialogPengingatTagihan(dynamic tagihan, dynamic tglJatuhTempo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.notifications_active_rounded, color: Colors.red.shade600, size: 36),
            ),
            const SizedBox(height: 14),
            const Text('Tagihan Bulan Ini Belum Dibayar',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Tagihan WiFi periode ${tagihan['bulan']} sebesar ${_formatRp(tagihan['nominal'])} jatuh tempo tanggal $tglJatuhTempo. Yuk segera selesaikan pembayaran!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatTagihanScreen()))
                      .then((_) => _loadDashboard());
                },
                child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Ingatkan Nanti', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetSesiHotspot() async {
    final ok = await PelangganService().resetHotspotSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
          content: Text(ok ? 'Sesi perangkat Hotspot berhasil di-reset!' : 'Gagal reset sesi'),
        ),
      );
      _loadDashboard();
    }
  }

  void _bukaNotifikasiPelanggan(Map<String, dynamic> user, dynamic tagihanAktif) {
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
            const Text('Notifikasi Tagihan & Layanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            if (tagihanAktif == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Tidak ada tagihan tertunggak. Terima kasih sudah membayar tepat waktu!', style: TextStyle(color: Colors.grey))),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.red.shade100, child: Icon(Icons.receipt_long_rounded, color: Colors.red.shade700)),
                  title: Text('Tagihan ${tagihanAktif['bulan']} Belum Lunas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('${_formatRp(tagihanAktif['nominal'])} • Jatuh tempo tgl ${user['tgl_jatuh_tempo'] ?? 10}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatTagihanScreen())).then((_) => _loadDashboard());
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _data?['user'] ?? {};
    final koneksi = _data?['statistik_koneksi'] ?? {};
    final isOnline = koneksi['online'] == true;
    final serviceType = (user['service_type'] ?? 'pppoe').toString().toLowerCase();
    final tagihanAktif = _data?['tagihan_bulan_ini'];
    final statusTagihan = (tagihanAktif?['status'] ?? '').toString().toLowerCase();
    final isPendingTf = statusTagihan == 'pending';
    final hasUnpaidBill = tagihanAktif != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: CustomScrollView(
                slivers: [
                  // HEADER MODERN PELANGGAN
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 52, 20, 26),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('YASAHABA WIFI', style: TextStyle(color: Colors.indigo.shade200, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                                    const SizedBox(height: 2),
                                    Text(
                                      user['nama_lengkap'] ?? 'Pelanggan',
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                                        child: IconButton(
                                          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                                          onPressed: () => _bukaNotifikasiPelanggan(user, tagihanAktif),
                                        ),
                                      ),
                                      if (hasUnpaidBill)
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                            child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                                    child: IconButton(
                                      icon: const Icon(Icons.person_rounded, color: Colors.white),
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilPelangganScreen())),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // KARTU PAKET, ROUTER & STATISTIK UPTIME / PEMAKAIAN
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Icon(serviceType == 'hotspot' ? Icons.wifi_tethering_rounded : Icons.router_rounded,
                                              size: 15, color: const Color(0xFF4F46E5)),
                                          const SizedBox(width: 6),
                                          Text(
                                            serviceType == 'hotspot' ? 'HOTSPOT WIFI' : 'FIBER PPPOE',
                                            style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isOnline ? const Color(0xFFDCFCE7) : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle, size: 8, color: isOnline ? Colors.green : Colors.grey),
                                          const SizedBox(width: 5),
                                          Text(
                                            isOnline ? 'ONLINE' : 'OFFLINE',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(user['nama_paket'] ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text('Jatuh tempo setiap tanggal ${user['tgl_jatuh_tempo'] ?? 10}', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),

                                // KOTAK REALTIME UPTIME & PEMAKAIAN KUOTA
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _statItem(
                                          Icons.timer_outlined,
                                          'Uptime Sesi',
                                          isOnline ? (koneksi['uptime'] ?? '-') : 'Offline',
                                          isOnline ? const Color(0xFF4F46E5) : Colors.grey,
                                        ),
                                      ),
                                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                                      Expanded(
                                        child: _statItem(
                                          Icons.south_rounded,
                                          'Download',
                                          koneksi['download'] ?? '0 MB',
                                          const Color(0xFF059669),
                                        ),
                                      ),
                                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                                      Expanded(
                                        child: _statItem(
                                          Icons.north_rounded,
                                          'Upload',
                                          koneksi['upload'] ?? '0 MB',
                                          const Color(0xFFEA580C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (serviceType == 'hotspot') ...[
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Akun Login Hotspot', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                          Text('${user['hotspot_username'] ?? '-'}  •  ${user['hotspot_password'] ?? '-'}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                                        child: Text('${user['active_devices'] ?? 0}/${user['max_devices'] ?? 2} HP',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF4F46E5)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.phonelink_erase_rounded, size: 18, color: Color(0xFF4F46E5)),
                                      label: const Text('Reset Sesi Login Perangkat HP', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
                                      onPressed: _resetSesiHotspot,
                                    ),
                                  ),
                                ],
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
                        // NOTIFIKASI BANNER TAGIHAN BULAN INI
                        InkWell(
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatTagihanScreen()));
                            _loadDashboard();
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: !hasUnpaidBill
                                  ? const Color(0xFFECFDF5)
                                  : (isPendingTf ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2)),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: !hasUnpaidBill
                                    ? Colors.green.shade200
                                    : (isPendingTf ? Colors.amber.shade300 : Colors.red.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: !hasUnpaidBill
                                      ? Colors.green.shade100
                                      : (isPendingTf ? Colors.amber.shade100 : Colors.red.shade100),
                                  child: Icon(
                                    !hasUnpaidBill
                                        ? Icons.check_circle_rounded
                                        : (isPendingTf ? Icons.hourglass_top_rounded : Icons.warning_amber_rounded),
                                    color: !hasUnpaidBill
                                        ? Colors.green.shade700
                                        : (isPendingTf ? Colors.amber.shade800 : Colors.red.shade700),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        !hasUnpaidBill
                                            ? 'Tagihan Bulan Ini Lunas'
                                            : (isPendingTf
                                                ? 'Menunggu Verifikasi Transfer'
                                                : 'Tagihan ${tagihanAktif['bulan']} Belum Dibayar!'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                          color: !hasUnpaidBill ? Colors.green.shade900 : (isPendingTf ? Colors.amber.shade900 : Colors.red.shade900),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        !hasUnpaidBill
                                            ? 'Terima kasih, pembayaran bulan ini sudah aman'
                                            : '${_formatRp(tagihanAktif['nominal'])} • Jatuh tempo tgl ${user['tgl_jatuh_tempo'] ?? 10}',
                                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasUnpaidBill && !isPendingTf)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(10)),
                                    child: const Text('Bayar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  )
                                else
                                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // MENU LAYANAN MANDIRI
                        const Text('Layanan Mandiri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _menuTile(Icons.payments_rounded, 'Riwayat &\nBayar Tagihan', 'Upload bukti transfer', const Color(0xFF0D9488), () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatTagihanScreen()));
                              _loadDashboard();
                            }),
                            _menuTile(Icons.smart_toy_rounded, 'Asisten AI\nYasahaba', 'Tanya kendala 24 jam', const Color(0xFF7C3AED), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatAiScreen()));
                            }),
                            _menuTile(Icons.upgrade_rounded, 'Ubah / Upgrade\nPaket WiFi', 'Sesuaikan kecepatan', const Color(0xFFEA580C), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const UbahPaketScreen()));
                            }),
                            _menuTile(Icons.support_agent_rounded, 'Lapor Gangguan\nJaringan', 'Kirim foto router', const Color(0xFFE11D48), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporGangguanScreen()));
                            }),
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

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
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
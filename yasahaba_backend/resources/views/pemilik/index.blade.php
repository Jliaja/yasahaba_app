<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Executive Command Center - Yasahaba Wifi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; background-color: #f8fafc; }</style>
</head>
<body class="flex h-screen overflow-hidden text-slate-800">

    <!-- SIDEBAR -->
    <aside class="w-64 bg-slate-900 text-slate-300 flex flex-col hidden md:flex border-r border-slate-800">
        <div class="h-16 flex items-center px-6 font-bold text-lg text-white tracking-wider border-b border-slate-800">
            <span class="text-indigo-400 mr-2 text-xl">⚡</span> YASAHABA ISP
        </div>
        <nav class="flex-1 px-4 py-6 space-y-1.5 text-sm font-medium">
            <a href="#" class="flex items-center px-4 py-3 bg-indigo-600 text-white rounded-xl shadow-lg shadow-indigo-600/20">
                📊 Ringkasan Eksekutif
            </a>
            <a href="#pelanggan" class="flex items-center px-4 py-3 hover:bg-slate-800 hover:text-white rounded-xl transition">
                👥 Data Pelanggan & Isolir
            </a>
            <a href="#infrastruktur" class="flex items-center px-4 py-3 hover:bg-slate-800 hover:text-white rounded-xl transition">
                🖧 OLT & Status Jaringan
            </a>
            <a href="#approval" class="flex items-center px-4 py-3 hover:bg-slate-800 hover:text-white rounded-xl transition">
                📝 Approval Registrasi <span class="ml-auto bg-indigo-500 text-white text-xs px-2 py-0.5 rounded-full">{{ $pendaftaranBaru->count() }}</span>
            </a>
        </nav>
        <div class="p-4 border-t border-slate-800">
            <div class="text-xs text-slate-500 uppercase font-semibold">Login sebagai:</div>
            <div class="font-bold text-white text-sm">Owner Yasahaba</div>
        </div>
    </aside>

    <!-- MAIN CONTENT WRAPPER -->
    <main class="flex-1 flex flex-col h-screen overflow-y-auto">
        
        <!-- HEADER -->
        <header class="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-8 sticky top-0 z-20">
            <h1 class="text-lg font-bold text-slate-900">Dashboard Utama Pemilik</h1>
            <div class="flex items-center gap-4">
                <span class="text-xs font-semibold bg-emerald-50 text-emerald-600 px-3 py-1.5 rounded-full border border-emerald-200">🟢 Sistem Normal</span>
                <form action="{{ route('logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="bg-slate-100 text-slate-600 px-4 py-2 rounded-lg text-xs font-bold hover:bg-slate-200 transition">
                        Logout
                    </button>
                </form>
            </div>
        </header>

        <div class="p-8 max-w-7xl w-full mx-auto space-y-8">
            
            @if(session('success'))
                <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 p-4 rounded-xl shadow-sm flex items-center gap-3">
                    <span class="text-xl">✅</span>
                    <div class="text-sm font-semibold">{{ session('success') }}</div>
                </div>
            @endif

            <!-- 1. EXECUTIVE SUMMARY (FINANCIAL & STATS) -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-5">
                <!-- Pemasukan -->
                <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm">
                    <div class="text-xs font-bold text-slate-400 uppercase tracking-wider">Pemasukan Bulan Ini</div>
                    <div class="text-2xl font-black text-slate-900 mt-2">Rp {{ number_format($pemasukanBulanIni, 0, ',', '.') }}</div>
                    <div class="text-xs text-emerald-600 font-semibold mt-1">Bulan lalu: Rp {{ number_format($pendapatanBulanLalu, 0, ',', '.') }}</div>
                </div>

                <!-- Piutang / Nunggak -->
                <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm">
                    <div class="text-xs font-bold text-slate-400 uppercase tracking-wider">Total Piutang Macet</div>
                    <div class="text-2xl font-black text-rose-600 mt-2">Rp {{ number_format($totalPiutangMacet, 0, ',', '.') }}</div>
                    <div class="text-xs text-slate-500 font-medium mt-1">Tagihanlewat jatuh tempo</div>
                </div>

                <!-- Pelanggan Aktif -->
                <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm">
                    <div class="text-xs font-bold text-slate-400 uppercase tracking-wider">Pelanggan Aktif</div>
                    <div class="text-2xl font-black text-indigo-600 mt-2">{{ $pelangganAktif }} <span class="text-sm font-normal text-slate-400">/ {{ $totalPelanggan }}</span></div>
                    <div class="text-xs text-slate-500 font-medium mt-1">Layanan Fiber & Hotspot</div>
                </div>

                <!-- Terisolir -->
                <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm">
                    <div class="text-xs font-bold text-slate-400 uppercase tracking-wider">Pelanggan Terisolir</div>
                    <div class="text-2xl font-black text-amber-600 mt-2">{{ $pelangganIsolir }} <span class="text-sm font-normal text-slate-400">User</span></div>
                    <div class="text-xs text-slate-500 font-medium mt-1">Blokir otomatis MikroTik</div>
                </div>
            </div>

            <!-- 2. QUICK ACTIONS & BROADCAST -->
            <div class="bg-gradient-to-r from-indigo-900 to-slate-900 rounded-2xl p-6 text-white shadow-xl flex flex-col md:flex-row justify-between items-center gap-6">
                <div>
                    <h2 class="text-lg font-bold">📢 Broadcast Pesan WhatsApp Massal</h2>
                    <p class="text-slate-300 text-xs mt-1">Kirim pengumuman maintenance atau info tagihan langsung ke seluruh nomor pelanggan.</p>
                </div>
                <form action="{{ route('pemilik.broadcast') }}" method="POST" class="flex w-full md:w-auto gap-2">
                    @csrf
                    <input type="text" name="pesan" placeholder="Tulis pengumuman di sini..." required class="px-4 py-2.5 rounded-xl bg-slate-800 border border-slate-700 text-sm text-white placeholder-slate-400 focus:outline-none focus:border-indigo-500 w-full md:w-80">
                    <button type="submit" class="bg-indigo-600 hover:bg-indigo-500 text-white font-bold px-5 py-2.5 rounded-xl text-sm transition shrink-0">Kirim Blast</button>
                </form>
            </div>

            <!-- GRID 2 KOLOM: APPROVAL & INFRASTRUKTUR OLT -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8" id="approval">
                
                <!-- 3. VERIFIKASI PENDAFTARAN & OCR KTP -->
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden flex flex-col">
                    <div class="px-6 py-5 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
                        <h2 class="font-bold text-slate-900 text-sm">Validasi Pendaftaran Baru (OCR KTP)</h2>
                        <span class="bg-indigo-50 text-indigo-600 text-xs font-bold px-2.5 py-1 rounded-full border border-indigo-100">{{ $pendaftaranBaru->count() }} Antrean</span>
                    </div>
                    <div class="divide-y divide-slate-100 overflow-x-auto flex-1">
                        @forelse($pendaftaranBaru as $reg)
                            <div class="p-5 flex items-center justify-between hover:bg-slate-50/50 transition">
                                <div>
                                    <div class="font-bold text-sm text-slate-900">{{ $reg->nama_lengkap }}</div>
                                    <div class="text-xs text-slate-500 mt-0.5">📞 {{ $reg->no_wa }}</div>
                                    <div class="text-xs text-slate-600 mt-1 max-w-xs truncate">📍 {{ $reg->alamat_pemasangan }}</div>
                                </div>
                                <form action="{{ route('pemilik.acc', $reg->id) }}" method="POST" class="flex gap-2">
                                    @csrf
                                    <button type="submit" name="action" value="terima" class="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold px-3.5 py-2 rounded-xl transition shadow-sm">ACC</button>
                                    <button type="submit" name="action" value="tolak" class="bg-rose-100 hover:bg-rose-200 text-rose-700 text-xs font-bold px-3.5 py-2 rounded-xl transition">Tolak</button>
                                </form>
                            </div>
                        @empty
                            <div class="p-8 text-center text-slate-400 text-xs font-medium">Belum ada antrean pendaftaran baru.</div>
                        @endforelse
                    </div>
                </div>

                <!-- 4. MONITORING OLT & REDAMAN SINYAL -->
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden flex flex-col" id="infrastruktur">
                    <div class="px-6 py-5 border-b border-slate-100 bg-slate-50/50 flex justify-between items-center">
                        <h2 class="font-bold text-slate-900 text-sm">Status Redaman Sinyal OLT HiOSO</h2>
                        <span class="text-xs text-slate-400 font-semibold">*Live SNMP Polling</span>
                    </div>
                    <div class="overflow-x-auto flex-1">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="text-[11px] font-bold text-slate-400 uppercase tracking-wider bg-slate-50/30">
                                    <th class="px-6 py-3">Port PON</th>
                                    <th class="px-6 py-3">ONU ID</th>
                                    <th class="px-6 py-3">RX Power</th>
                                    <th class="px-6 py-3">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 text-xs font-medium">
                                @foreach($dataOlt as $olt)
                                    <tr class="hover:bg-slate-50/50 transition">
                                        <td class="px-6 py-3.5 font-bold text-slate-700">PON {{ $olt->pon }}</td>
                                        <td class="px-6 py-3.5 text-slate-600">ONU {{ $olt->onu }}</td>
                                        <td class="px-6 py-3.5 font-mono font-bold {{ $olt->rx_power < -25 ? 'text-rose-600' : 'text-slate-800' }}">
                                            {{ $olt->rx_power }}
                                        </td>
                                        <td class="px-6 py-3.5">
                                            @if($olt->status == 'online')
                                                <span class="bg-emerald-50 text-emerald-700 px-2.5 py-1 rounded-md font-bold text-[10px] border border-emerald-200">ONLINE</span>
                                            @else
                                                <span class="bg-rose-50 text-rose-700 px-2.5 py-1 rounded-md font-bold text-[10px] border border-rose-200 animate-pulse">KRITIS / DROP</span>
                                            @endif
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>

        </div>
    </main>

</body>
</html>
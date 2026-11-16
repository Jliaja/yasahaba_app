<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pelanggan;
use App\Models\Bill;
use App\Models\Ticket;
use App\Models\Package;
use App\Services\MikrotikService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;

class CustomerController extends Controller
{
    public function onboardingKtp(Request $request)
    {
        $request->validate([
            'nik'          => 'required|digits:16',
            'nama_lengkap' => 'required|string|max:150',
            'email'        => 'required|email',
            'no_hp'        => 'required|string|max:20',
            'foto_ktp'     => 'required|image|max:5120',
        ]);

        $pelanggan =$request->user();
        $path      =$request->file('foto_ktp')->store('ktp_pelanggan', 'public');

        $pelanggan->update([
            'nik'          => $request->nik,
            'nama_lengkap' => $request->nama_lengkap,
            'email'        => $request->email,
            'no_wa'        => $request->no_hp,
            'foto_ktp'     => $path,
        ]);

        return response()->json(['status' => 'success', 'message' => 'Data KTP & profil berhasil disimpan']);
    }

    public function dashboard(Request $request, MikrotikService$mikrotik)
    {
        $pelanggan      = Pelanggan::with('paket')->find($request->user()->id);
        $serviceType    =$pelanggan->service_type ?? 'pppoe';
        $usernameTarget =$serviceType === 'hotspot'
            ? ($pelanggan->hotspot_username ?? $pelanggan->username)
            : $pelanggan->username;

        // Tarik uptime & pemakaian kuota real-time dari MikroTik
        $statistikKoneksi =$mikrotik->getUserSessionStats($serviceType, (string)$usernameTarget);

        $tagihanAktif = Bill::where('pelanggan_id',$pelanggan->id)
            ->whereIn('status', ['belum_lunas', 'belum_dibayar', 'pending'])
            ->orderBy('created_at', 'desc')
            ->first();

        return response()->json([
            'status' => 'success',
            'user'   => [
                'nama_lengkap'     => $pelanggan->nama_lengkap,
                'service_type'     => $serviceType,
                'status_koneksi'   => strtoupper($pelanggan->status ?? 'AKTIF'),
                'nama_paket'       => $pelanggan->paket->nama_paket ?? '-',
                'kecepatan'        => $pelanggan->paket->deskripsi ?? '-',
                'tgl_jatuh_tempo'  => $pelanggan->tgl_jatuh_tempo ?? 10,
                'hotspot_username' => $pelanggan->username,
                'hotspot_password' => $pelanggan->hotspot_password ?? '-',
                'active_devices'   => $pelanggan->active_devices ?? 1,
                'max_devices'      => $pelanggan->max_devices ?? 2,
            ],
            'statistik_koneksi' => $statistikKoneksi,
            'tagihan_bulan_ini' => $tagihanAktif ? [
                'id'      => $tagihanAktif->id,
                'bulan'   => $tagihanAktif->periode ?? $tagihanAktif->bulan ?? date('F Y', strtotime($tagihanAktif->created_at)),
                'nominal' => $tagihanAktif->total_tagihan,
                'status'  => $tagihanAktif->status == 'belum_dibayar' ? 'belum_lunas' :$tagihanAktif->status,
            ] : null,
        ]);
    }

    public function resetHotspotSession(Request $request)
    {
        $pelanggan                 = $request->user();$pelanggan->active_devices = 0;
        $pelanggan->save();

        return response()->json(['status' => 'success', 'message' => 'Sesi perangkat Hotspot berhasil di-reset']);
    }

    public function tagihan(Request $request)
    {
        $bills = Bill::where('pelanggan_id',$request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($b) {
                return [
                    'id'           => $b->id,
                    'bulan'        => $b->periode ?? $b->bulan ?? date('F Y', strtotime($b->created_at)),
                    'nominal'      => $b->total_tagihan,
                    'status'       => $b->status == 'belum_dibayar' ? 'belum_lunas' :$b->status,
                    'metode_bayar' => $b->metode_bayar,
                    'tgl_lunas'    => $b->status == 'lunas' ?$b->updated_at->format('d M Y H:i') : null,
                ];
            });

        return response()->json(['status' => 'success', 'data' => $bills]);
    }

    public function uploadBuktiTransfer(Request $request,$id)
    {
        $request->validate(['bukti_transfer' => 'required|image|max:5120']);

        $bill = Bill::where('pelanggan_id', $request->user()->id)->findOrFail($id);
        $path =$request->file('bukti_transfer')->store('bukti_transfer', 'public');

        $bill->update([
            'status'         => 'pending',
            'metode_bayar'   => 'transfer',
            'bukti_transfer' => $path,
        ]);

        return response()->json(['status' => 'success', 'message' => 'Bukti transfer terkirim, status PENDING menunggu ACC Pemilik']);
    }

    public function getDaftarPaket()
    {
        $packages = Package::all()->map(function ($p) {
            return [
                'id'           => $p->id,
                'nama_paket'   => $p->nama_paket,
                'service_type' => $p->service_type ?? 'pppoe',
                'harga'        => $p->harga,
                'deskripsi'    => $p->deskripsi ?? '',
            ];
        });

        return response()->json(['status' => 'success', 'data' => $packages]);
    }

    public function ajukanUbahPaket(Request $request)
    {
        $request->validate([
            'paket_baru_id' => 'required|exists:packages,id',
            'catatan'       => 'nullable|string',
        ]);

        $pelanggan =$request->user();

        DB::table('package_change_requests')->insert([
            'pelanggan_id'  => $pelanggan->id,
            'paket_lama_id' => $pelanggan->package_id,
            'paket_baru_id' => $request->paket_baru_id,
            'diajukan_oleh' => 'Pelanggan (' . $pelanggan->nama_lengkap . ')',
            'catatan'       => $request->catatan,
            'status'        => 'pending',
            'created_at'    => now(),
            'updated_at'    => now(),
        ]);

        return response()->json(['status' => 'success', 'message' => 'Pengajuan ubah paket terkirim']);
    }

    public function askAi(Request $request)
    {
        $request->validate(['message' => 'required|string']);
        $pelanggan = Pelanggan::with('paket')->find($request->user()->id);

        $tagihanBelumLunas = Bill::where('pelanggan_id',$pelanggan->id)
            ->whereIn('status', ['belum_lunas', 'belum_dibayar', 'pending'])
            ->first();

        $knowledgeBase      = DB::table('ai_settings')->where('key', 'knowledge_base')->value('value') ?? 'Belum ada SOP tambahan.';$broadcastAktif     = DB::table('broadcasts')->latest()->first();
        $infoGangguanMassal =$broadcastAktif ? "{$broadcastAktif->judul}: {$broadcastAktif->pesan}" : 'Tidak ada gangguan massal saat ini.';

        $systemPrompt = "Kamu adalah Asisten AI resmi ISP Yasahaba WiFi. Jawab ramah, singkat, dan solutif dalam Bahasa Indonesia.\n"
            . "DATA PELANGGAN SAAT INI:\n"
            . "- Nama: {$pelanggan->nama_lengkap}\n"
            . '- Jenis Layanan Router: ' . strtoupper($pelanggan->service_type ?? 'pppoe') . "\n"
            . '- Paket: ' . ($pelanggan->paket->nama_paket ?? '-') . "\n"
            . "- Status Koneksi: {$pelanggan->status}\n"
            . '- Status Tagihan Aktif: ' . ($tagihanBelumLunas ? "Rp {$tagihanBelumLunas->total_tagihan} ({$tagihanBelumLunas->status})" : 'Sudah Lunas') . "\n"
            . "INFO GANGGUAN MASSAL TERBARU: {$infoGangguanMassal}\n"
            . "SOP & ATURAN YASAHABA DARI PEMILIK:\n{$knowledgeBase}\n\n"
            . "PANDUAN TROUBLESHOOTING:\n"
            . "- Jika ada tagihan belum lunas, ingatkan pelanggan untuk segera melakukan pembayaran.\n"
            . "- Jika layanan HOTSPOT dan tidak bisa login, sarankan cek batas perangkat HP atau klik tombol 'Reset Sesi Login Perangkat HP' di beranda.\n"
            . '- Jika layanan PPPOE dan lampu LOS router merah/berkedip, sarankan kirim Tiket Gangguan di aplikasi agar teknisi mengecek kabel optik.';

        $apiKey   = config('services.gemini.key') ?? env('GEMINI_API_KEY');
        $response = Http::post("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={$apiKey}", [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $systemPrompt . "\n\nPertanyaan Pelanggan: " . $request->message],
                    ],
                ],
            ],
        ]);

        $reply =$response->json('candidates.0.content.parts.0.text') ?? 'Maaf, Asisten AI sedang sibuk. Silakan coba beberapa saat lagi atau kirim Tiket Gangguan.';

        return response()->json(['status' => 'success', 'reply' => $reply]);
    }

    public function submitTiket(Request $request)
    {
        $request->validate([
            'judul'       => 'required|string|max:120',
            'deskripsi'   => 'required|string',
            'foto_router' => 'nullable|image|max:5120',
        ]);

        $fotoPath =$request->hasFile('foto_router')
            ? $request->file('foto_router')->store('tiket_router', 'public')
            : null;

        Ticket::create([
            'pelanggan_id'  => $request->user()->id,
            'judul_keluhan' => $request->judul,
            'deskripsi'     => $request->deskripsi,
            'foto_router'   => $fotoPath,
            'status'        => 'menunggu',
        ]);

        return response()->json(['status' => 'success', 'message' => 'Tiket gangguan terkirim ke Pemilik']);
    }
}
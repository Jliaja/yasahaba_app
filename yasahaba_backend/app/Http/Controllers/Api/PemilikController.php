<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Bill;
use App\Models\Pelanggan;
use App\Models\User;
use App\Models\Package;
use App\Models\Ticket;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class PemilikController extends Controller
{
    public function dashboard()
    {
        $pemasukanTransfer = Bill::where('status', 'lunas')
            ->where('metode_bayar', 'transfer')
            ->whereMonth('updated_at', now()->month)
            ->sum('total_tagihan');

        $pemasukanTunai = Bill::where('status', 'lunas')
            ->where('metode_bayar', 'cash')
            ->whereMonth('updated_at', now()->month)
            ->sum('total_tagihan');

        return response()->json([
            'status' => 'success',
            'total_pemasukan' => $pemasukanTransfer + $pemasukanTunai,
            'pemasukan_transfer' => $pemasukanTransfer,
            'pemasukan_tunai' => $pemasukanTunai,
            'total_pelanggan' => Pelanggan::count(),
            'belum_lunas' => Bill::whereIn('status', ['belum_lunas', 'belum_dibayar'])->count(),
            'transfer_pending' => Bill::where('status', 'pending')->count(),
        ]);
    }

    public function getDaftarPaket()
    {
        return response()->json(['status' => 'success', 'data' => Package::all()]);
    }

    public function tambahPaket(Request $request)
    {
        $request->validate([
            'nama_paket' => 'required|string',
            'service_type' => 'required|in:pppoe,hotspot',
            'harga' => 'required|numeric',
            'deskripsi' => 'nullable|string'
        ]);

        Package::create($request->only('nama_paket', 'service_type', 'harga', 'deskripsi'));
        return response()->json(['status' => 'success', 'message' => 'Paket ditambahkan']);
    }

    public function buatAkunUser(Request $request)
    {
        $request->validate([
            'role' => 'required|in:pelanggan,penagih',
            'nama' => 'required|string',
            'username' => 'required|string',
            'password' => 'required|min:6',
        ]);

        if ($request->role === 'penagih') {
            User::create([
                'name' => $request->nama,
                'email' => $request->username,
                'password' => Hash::make($request->password),
                'role' => 'penagih',
            ]);
        } else {
            $paket = Package::find($request->paket_id);
            Pelanggan::create([
                'nama_lengkap' => $request->nama,
                'username' => $request->username,
                'password' => Hash::make($request->password),
                'hotspot_password' => ($paket->service_type ?? '') === 'hotspot' ? $request->password : null,
                'alamat' => $request->alamat,
                'package_id' => $request->paket_id,
                'service_type' => $paket->service_type ?? 'pppoe',
                'tgl_jatuh_tempo' => $request->tgl_jatuh_tempo ?? 10,
                'status' => 'aktif',
            ]);
        }

        return response()->json(['status' => 'success', 'message' => 'Akun berhasil dibuat']);
    }

    public function exportPelangganIsp()
    {
        $pelangganList = Pelanggan::with('paket')->get();
        $filename = 'laporan_pelanggan_yasahaba_' . date('Ymd') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
        ];

        $callback = function () use ($pelangganList) {
            $file = fopen('php://output', 'w');
            fputcsv($file, ['No', 'NIK', 'Nama Lengkap (KTP)', 'Email', 'No HP/WA', 'Alamat', 'Jenis Layanan', 'Paket', 'Status']);

            foreach ($pelangganList as $idx => $c) {
                fputcsv($file, [
                    $idx + 1,
                    "'" . ($c->nik ?? '-'),
                    $c->nama_lengkap,
                    $c->email ?? '-',
                    $c->no_wa ?? '-',
                    $c->alamat ?? '-',
                    strtoupper($c->service_type ?? 'pppoe'),
                    $c->paket->nama_paket ?? '-',
                    strtoupper($c->status),
                ]);
            }
            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    public function generateTagihanBulanan(Request $request)
    {
        $request->validate(['bulan' => 'required|string']);
        $pelangganList = Pelanggan::with('paket')->where('status', 'aktif')->get();

        foreach ($pelangganList as $c) {
            if (!$c->paket || $c->paket->harga <= 0) continue; // skip paket CSR gratis (harga 0)

            $exists = Bill::where('pelanggan_id', $c->id)->where('periode', $request->bulan)->exists();
            if ($exists) continue;

            Bill::create([
                'pelanggan_id' => $c->id,
                'periode' => $request->bulan,
                'total_tagihan' => $c->paket->harga,
                'status' => 'belum_lunas',
                'jatuh_tempo' => now()->setDay(min($c->tgl_jatuh_tempo ?? 10, 28)),
            ]);

            if (!empty($c->email)) {
                Mail::raw(
                    "Halo {$c->nama_lengkap},\n\nTagihan WiFi Yasahaba periode {$request->bulan} sebesar Rp {$c->paket->harga} telah terbit.\nSilakan lakukan pembayaran via transfer di aplikasi Yasahaba atau tunai melalui penagih.\n\nTerima kasih.",
                    function ($msg) use ($c, $request) {
                        $msg->to($c->email)->subject("Tagihan WiFi Yasahaba - {$request->bulan}");
                    }
                );
            }
        }

        return response()->json(['status' => 'success', 'message' => 'Tagihan bulanan berhasil diterbitkan']);
    }

    public function getAntreanTransferPending()
    {
        $bills = Bill::with('pelanggan')->where('status', 'pending')->get()->map(function ($b) {
            return [
                'id' => $b->id,
                'nama_pelanggan' => $b->pelanggan->nama_lengkap ?? '-',
                'bulan' => $b->periode ?? '-',
                'nominal' => $b->total_tagihan,
                'bukti_url' => $b->bukti_transfer ? asset('storage/' . $b->bukti_transfer) : null,
            ];
        });

        return response()->json(['status' => 'success', 'data' => $bills]);
    }

    public function verifikasiTransfer(Request $request, $id)
    {
        $request->validate(['aksi' => 'required|in:acc,tolak', 'alasan' => 'nullable|string']);
        $bill = Bill::with('pelanggan')->findOrFail($id);
        $pelanggan = $bill->pelanggan;

        if ($request->aksi === 'acc') {
            $bill->update(['status' => 'lunas']);
            if ($pelanggan) {
                $pelanggan->update(['status' => 'aktif']);

                if (!empty($pelanggan->email)) {
                    Mail::raw(
                        "Halo {$pelanggan->nama_lengkap},\n\nBukti transfer Anda untuk tagihan {$bill->periode} sebesar Rp {$bill->total_tagihan} telah DI-ACC oleh Pemilik.\nStatus: LUNAS.\n\nTerima kasih!",
                        function ($msg) use ($pelanggan) {
                            $msg->to($pelanggan->email)->subject('Struk Lunas Transfer - Yasahaba WiFi');
                        }
                    );
                }
            }
        } else {
            $bill->update(['status' => 'belum_lunas', 'bukti_transfer' => null]);

            if ($pelanggan && !empty($pelanggan->email)) {
                $alasan = $request->alasan ?? 'Bukti tidak valid/buram';
                Mail::raw(
                    "Halo {$pelanggan->nama_lengkap},\n\nMohon maaf, bukti transfer Anda untuk tagihan {$bill->periode} DITOLAK dengan alasan: {$alasan}.\nSilakan upload ulang bukti transfer yang jelas di aplikasi Yasahaba.",
                    function ($msg) use ($pelanggan) {
                        $msg->to($pelanggan->email)->subject('Bukti Transfer Ditolak - Yasahaba WiFi');
                    }
                );
            }
        }

        return response()->json(['status' => 'success', 'message' => 'Verifikasi transfer selesai']);
    }

    public function getAntreanSetoranPenagih()
    {
        $list = DB::table('collector_settlements')
            ->join('users', 'collector_settlements.penagih_id', '=', 'users.id')
            ->where('collector_settlements.status', 'pending')
            ->select('collector_settlements.*', 'users.name as nama_penagih')
            ->get()
            ->map(function ($s) {
                return [
                    'id' => $s->id,
                    'nama_penagih' => $s->nama_penagih,
                    'nominal' => $s->nominal,
                    'catatan' => $s->catatan,
                    'tanggal' => date('d M Y H:i', strtotime($s->created_at)),
                ];
            });

        return response()->json(['status' => 'success', 'data' => $list]);
    }

    public function validasiSetoranPenagih($id)
    {
        DB::table('collector_settlements')->where('id', $id)->update([
            'status' => 'verified',
            'updated_at' => now(),
        ]);

        return response()->json(['status' => 'success', 'message' => 'Setoran penagih tervalidasi']);
    }

    public function getPengajuanUbahPaket()
    {
        $list = DB::table('package_change_requests')
            ->join('pelanggan', 'package_change_requests.pelanggan_id', '=', 'pelanggan.id')
            ->leftJoin('packages as p_lama', 'package_change_requests.paket_lama_id', '=', 'p_lama.id')
            ->join('packages as p_baru', 'package_change_requests.paket_baru_id', '=', 'p_baru.id')
            ->where('package_change_requests.status', 'pending')
            ->select(
                'package_change_requests.*',
                'pelanggan.nama_lengkap as nama_pelanggan',
                'p_lama.nama_paket as paket_lama',
                'p_baru.nama_paket as paket_baru'
            )
            ->get();

        return response()->json(['status' => 'success', 'data' => $list]);
    }

    public function prosesUbahPaket(Request $request, $id)
    {
        $request->validate(['aksi' => 'required|in:acc,tolak']);
        $req = DB::table('package_change_requests')->where('id', $id)->first();
        $pelanggan = Pelanggan::find($req->pelanggan_id);
        $paketBaru = Package::find($req->paket_baru_id);

        if ($request->aksi === 'acc') {
            $pelanggan->update([
                'package_id' => $paketBaru->id,
                'service_type' => $paketBaru->service_type ?? $pelanggan->service_type,
            ]);
            DB::table('package_change_requests')->where('id', $id)->update(['status' => 'approved', 'updated_at' => now()]);

            if (!empty($pelanggan->email)) {
                Mail::raw("Halo {$pelanggan->nama_lengkap},\n\nPengajuan perubahan paket Anda ke {$paketBaru->nama_paket} (Rp {$paketBaru->harga}/bulan) telah DI-ACC oleh Pemilik.", function ($msg) use ($pelanggan) {
                    $msg->to($pelanggan->email)->subject('Perubahan Paket WiFi Disetujui - Yasahaba');
                });
            }
        } else {
            DB::table('package_change_requests')->where('id', $id)->update(['status' => 'rejected', 'updated_at' => now()]);
        }

        return response()->json(['status' => 'success', 'message' => 'Pengajuan ubah paket diproses']);
    }

    public function getTiketGangguan()
    {
        $tickets = Ticket::with('pelanggan')
            ->whereIn('status', ['menunggu', 'diproses', 'open'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($t) {
                return [
                    'id' => $t->id,
                    'nama_pelanggan' => $t->pelanggan->nama_lengkap ?? '-',
                    'judul' => $t->judul_keluhan,
                    'deskripsi' => $t->deskripsi,
                    'status' => $t->status == 'open' ? 'menunggu' : $t->status,
                ];
            });

        return response()->json(['status' => 'success', 'data' => $tickets]);
    }

    public function updateStatusTiket(Request $request, $id)
    {
        $request->validate(['status' => 'required|in:diproses,selesai']);
        $ticket = Ticket::with('pelanggan')->findOrFail($id);
        $ticket->update(['status' => $request->status]);

        if ($request->status === 'selesai' && $ticket->pelanggan && !empty($ticket->pelanggan->email)) {
            Mail::raw("Halo {$ticket->pelanggan->nama_lengkap},\n\nLaporan gangguan WiFi Anda ({$ticket->judul_keluhan}) telah SELESAI ditangani oleh teknisi Yasahaba. Silakan cek kembali koneksi internet Anda.", function ($msg) use ($ticket) {
                $msg->to($ticket->pelanggan->email)->subject('Perbaikan WiFi Selesai - Yasahaba');
            });
        }

        return response()->json(['status' => 'success', 'message' => 'Status tiket diperbarui']);
    }

    public function getAiKnowledge()
    {
        $content = DB::table('ai_settings')->where('key', 'knowledge_base')->value('value') ?? '';
        return response()->json(['status' => 'success', 'content' => $content]);
    }

    public function saveAiKnowledge(Request $request)
    {
        DB::table('ai_settings')->updateOrInsert(
            ['key' => 'knowledge_base'],
            ['value' => $request->content ?? '', 'updated_at' => now()]
        );
        return response()->json(['status' => 'success', 'message' => 'Knowledge Base AI disimpan']);
    }

    public function kirimBroadcastGangguan(Request $request)
    {
        $request->validate(['judul' => 'required|string', 'pesan' => 'required|string']);

        DB::table('broadcasts')->insert([
            'judul' => $request->judul,
            'pesan' => $request->pesan,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $emails = Pelanggan::whereNotNull('email')->where('email', '!=', '')->pluck('email');
        foreach ($emails as $email) {
            Mail::raw("INFO GANGGUAN YASAHABA WIFI\n\n{$request->judul}\n{$request->pesan}", function ($msg) use ($email, $request) {
                $msg->to($email)->subject('[INFO] ' . $request->judul);
            });
        }

        return response()->json(['status' => 'success', 'message' => 'Broadcast terkirim']);
    }
}
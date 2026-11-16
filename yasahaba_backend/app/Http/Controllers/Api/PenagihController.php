<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pelanggan;
use App\Models\Bill;
use App\Models\Ticket;
use App\Models\Package;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class PenagihController extends Controller
{
    public function dashboard(Request $request)
    {
        $penagihId = $request->user()->id;

        $uangDipegang = Bill::where('penagih_id', $penagihId)
            ->where('status', 'lunas')
            ->where('metode_bayar', 'cash')
            ->whereNull('settlement_id')
            ->sum('total_tagihan');

        $pelangganList = Pelanggan::with('paket')->orderBy('nama_lengkap', 'asc')->get()->map(function ($c) {
            $tagihan = Bill::where('pelanggan_id', $c->id)
                ->orderBy('created_at', 'desc')
                ->first();

            $statusTagihan = 'belum_lunas';
            if ($tagihan) {
                $statusTagihan = ($tagihan->status == 'belum_dibayar') ? 'belum_lunas' : $tagihan->status;
            }

            return [
                'id' => $c->id,
                'nama_lengkap' => $c->nama_lengkap,
                'alamat' => $c->alamat ?? '-',
                'no_hp' => $c->no_wa ?? '-',
                'service_type' => $c->service_type ?? 'pppoe',
                'nama_paket' => $c->paket->nama_paket ?? '-',
                'tagihan_id' => $tagihan->id ?? null,
                'nominal_tagihan' => $tagihan->total_tagihan ?? ($c->paket->harga ?? 0),
                'status_tagihan' => $statusTagihan,
            ];
        });

        return response()->json([
            'status' => 'success',
            'uang_dipegang' => $uangDipegang,
            'pelanggan' => $pelangganList,
        ]);
    }

    public function terimaTunai(Request $request, $tagihanId)
    {
        DB::beginTransaction();
        try {
            $bill = Bill::with('pelanggan')->findOrFail($tagihanId);

            if ($bill->status === 'lunas') {
                return response()->json(['status' => 'error', 'message' => 'Tagihan ini sudah lunas!'], 400);
            }

            $bill->update([
                'status' => 'lunas',
                'metode_bayar' => 'cash',
                'penagih_id' => $request->user()->id,
            ]);

            $pelanggan = $bill->pelanggan;
            if ($pelanggan) {
                $pelanggan->update(['status' => 'aktif']);

                if (!empty($pelanggan->email)) {
                    $penagihName = $request->user()->name;
                    Mail::raw(
                        "Halo {$pelanggan->nama_lengkap},\n\nPembayaran WiFi Yasahaba sebesar Rp {$bill->total_tagihan} telah diterima TUNAI oleh petugas ({$penagihName}) pada " . now()->format('d M Y H:i') . ".\nStatus: LUNAS.\n\nTerima kasih!",
                        function ($msg) use ($pelanggan) {
                            $msg->to($pelanggan->email)->subject('Struk Pembayaran Lunas - Yasahaba WiFi');
                        }
                    );
                }
            }

            DB::commit();
            return response()->json(['status' => 'success', 'message' => 'Pembayaran tunai berhasil dicatat']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getDaftarPaket()
    {
        $packages = Package::all()->map(function ($p) {
            return [
                'id' => $p->id,
                'nama_paket' => $p->nama_paket,
                'harga' => $p->harga,
            ];
        });
        return response()->json(['status' => 'success', 'data' => $packages]);
    }

    public function delegasiUbahPaket(Request $request)
    {
        $request->validate([
            'pelanggan_id' => 'required|exists:pelanggan,id',
            'paket_baru_id' => 'required|exists:packages,id',
            'catatan' => 'nullable|string'
        ]);

        $pelanggan = Pelanggan::findOrFail($request->pelanggan_id);

        DB::table('package_change_requests')->insert([
            'pelanggan_id' => $pelanggan->id,
            'paket_lama_id' => $pelanggan->package_id,
            'paket_baru_id' => $request->paket_baru_id,
            'diajukan_oleh' => 'Penagih: ' . $request->user()->name,
            'catatan' => $request->catatan,
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['status' => 'success', 'message' => 'Delegasi ubah paket masuk antrean Pemilik']);
    }

    public function delegasiTiketGangguan(Request $request)
    {
        $request->validate([
            'pelanggan_id' => 'required|exists:pelanggan,id',
            'judul' => 'required|string|max:120',
            'deskripsi' => 'required|string',
            'foto_router' => 'nullable|image|max:5120'
        ]);

        $fotoPath = $request->hasFile('foto_router')
            ? $request->file('foto_router')->store('tiket_router', 'public')
            : null;

        Ticket::create([
            'pelanggan_id' => $request->pelanggan_id,
            'judul_keluhan' => '[Via Penagih ' . $request->user()->name . '] ' . $request->judul,
            'deskripsi' => $request->deskripsi,
            'foto_router' => $fotoPath,
            'status' => 'menunggu'
        ]);

        return response()->json(['status' => 'success', 'message' => 'Delegasi tiket gangguan terkirim']);
    }

    public function getRekapSetoran(Request $request)
    {
        $penagihId = $request->user()->id;

        $totalBelumDisetor = Bill::where('penagih_id', $penagihId)
            ->where('status', 'lunas')
            ->where('metode_bayar', 'cash')
            ->whereNull('settlement_id')
            ->sum('total_tagihan');

        $riwayat = DB::table('collector_settlements')
            ->where('penagih_id', $penagihId)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($s) {
                return [
                    'id' => $s->id,
                    'nominal' => $s->nominal,
                    'status' => $s->status,
                    'catatan' => $s->catatan,
                    'tanggal' => date('d M Y H:i', strtotime($s->created_at)),
                ];
            });

        return response()->json([
            'status' => 'success',
            'total_belum_disetor' => $totalBelumDisetor,
            'riwayat' => $riwayat,
        ]);
    }

    public function ajukanSetoran(Request $request)
    {
        $penagihId = $request->user()->id;

        $bills = Bill::where('penagih_id', $penagihId)
            ->where('status', 'lunas')
            ->where('metode_bayar', 'cash')
            ->whereNull('settlement_id')
            ->get();

        $total = $bills->sum('total_tagihan');
        if ($total <= 0) {
            return response()->json(['status' => 'error', 'message' => 'Tidak ada uang tunai untuk disetor'], 400);
        }

        DB::beginTransaction();
        try {
            $settlementId = DB::table('collector_settlements')->insertGetId([
                'penagih_id' => $penagihId,
                'nominal' => $total,
                'catatan' => $request->catatan,
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            Bill::whereIn('id', $bills->pluck('id'))->update(['settlement_id' => $settlementId]);

            DB::commit();
            return response()->json(['status' => 'success', 'message' => 'Setoran diajukan ke Pemilik']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}
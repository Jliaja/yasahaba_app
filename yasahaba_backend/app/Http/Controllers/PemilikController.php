<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Bill;
use App\Models\pelanggan;
use App\Models\Registration;
use App\Models\Ticket;

class PemilikController extends Controller
{
    public function index()
    {
        // 1. Executive Summary & Financial
        $pemasukanBulanIni = Bill::where('status', 'lunas')
            ->whereMonth('updated_at', now()->month)
            ->sum('total_tagihan');

        $pendapatanBulanLalu = Bill::where('status', 'lunas')
            ->whereMonth('updated_at', now()->subMonth()->month)
            ->sum('total_tagihan');

        $totalPiutangMacet = Bill::where('status', 'belum_dibayar')
            ->whereDate('jatuh_tempo', '<', now())
            ->sum('total_tagihan');

        // 2. Infrastruktur & Pelanggan
        $totalPelanggan = pelanggan::count();
        $pelangganAktif = pelanggan::where('status', 'aktif')->count();
        $pelangganIsolir = pelanggan::where('status', 'isolir')->count();

        // 3. Meja Approval (OCR / Registrasi Pending)
        $pendaftaranBaru = Registration::where('status', 'pending')->get();

        // 4. Tiket Eskalasi Gangguan
        $tiketGangguan = Ticket::with('pelanggan')->where('status', '!=', 'resolved')->get();

        // 5. Dummy Data OLT & Traffic Gateway (bisa disesuaikan SNMP / Mikrotik API asli nanti)
        $dataOlt = [
            (object)['pon' => 1, 'onu' => '1', 'rx_power' => '-19.5 dBm', 'status' => 'online'],
            (object)['pon' => 1, 'onu' => '2', 'rx_power' => '-22.1 dBm', 'status' => 'online'],
            (object)['pon' => 2, 'onu' => '1', 'rx_power' => '-28.4 dBm', 'status' => 'kritis'], // Drop di bawah -25
        ];

        return view('pemilik.index', compact(
            'pemasukanBulanIni',
            'pendapatanBulanLalu',
            'totalPiutangMacet',
            'totalPelanggan',
            'pelangganAktif',
            'pelangganIsolir',
            'pendaftaranBaru',
            'tiketGangguan',
            'dataOlt'
        ));
    }

    // Aksi ACC / Tolak Pendaftaran KTP/OCR
    public function accPendaftaran(Request $request, $id)
    {
        $reg = Registration::findOrFail($id);
        
        if ($request->action == 'terima') {
            pelanggan::create([
                'nama_lengkap' => $reg->nama_lengkap,
                'no_wa' => $reg->no_wa,
                'alamat' => $reg->alamat_pemasangan,
                'package_id' => $reg->package_id,
                'status' => 'aktif'
            ]);
            $reg->update(['status' => 'aktif']);
            $pesan = 'Pendaftaran divalidasi, pelanggan resmi aktif!';
        } else {
            $reg->update(['status' => 'ditolak']);
            $pesan = 'Pendaftaran ditolak.';
        }

        return redirect()->route('pemilik.index')->with('success', $pesan);
    }

    // Aksi Tombol Darurat: Buka Isolir Manual
    public function bukaIsolirManual(Request $request, $id)
    {
        $pelanggan = pelanggan::findOrFail($id);
        $pelanggan->update(['status' => 'aktif']);

        // TODO: Tambahin logic nembak RouterOS API Mikrotik buat remove address-list isolir di sini

        return redirect()->route('pemilik.index')->with('success', "Isolir untuk pelanggan {$pelanggan->nama_lengkap} berhasil dibuka paksa!");
    }

    // Aksi Broadcast WA Massal
    public function broadcastWa(Request $request)
    {
        $request->validate(['pesan' => 'required|string']);

        // TODO: Eksekusi tembak API WhatsApp Gateway (Fonnte/Wablas) ke semua no_wa pelanggan

        return redirect()->route('pemilik.index')->with('success', 'Broadcast WhatsApp berhasil dijadwalkan ke seluruh pelanggan!');
    }
}
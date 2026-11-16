<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Package;
use App\Models\Coverage;
use App\Models\Registration;

class PemasaranController extends Controller
{
    // nampilin halaman landing page
    public function index()
    {
        // narik paket yang aktif doang, diurutin dari yang termurah
        $packages = Package::where('is_active', true)->orderBy('harga', 'asc')->get();
        // nampilin semua area
        $coverages = Coverage::all();

        return view('pemasaran.index', compact('packages', 'coverages'));
    }

    // nge-handle form pendaftaran
    public function daftar(Request $request)
    {
        // ini best practice: SELALU validasi inputan user, jangan gampang percaya!
        $validated = $request->validate([
            'nama_lengkap' => 'required|string|max:100',
            'no_wa' => 'required|numeric|digits_between:10,15',
            'alamat_pemasangan' => 'required|string',
            'package_id' => 'required|exists:packages,id',
        ], [
            'no_wa.numeric' => 'nomor wa harus angka, jangan masukin huruf.',
            'package_id.exists' => 'paket nggak valid, jangan ngide inspect element.'
        ]);

        Registration::create($validated);

        // balikin ke halaman depan bawa flash message sukses
        return redirect()->route('pemasaran.index')->with('success', 'mantap! pendaftaran lu udah masuk antrean. tunggu tim kita wa ya.');
    }
}
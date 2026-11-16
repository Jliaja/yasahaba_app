<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Pelanggan;
use App\Models\Package;
use Illuminate\Support\Facades\Hash;

class PelangganSeeder extends Seeder
{
    public function run(): void
    {
        $file = fopen(database_path('seeders/pelanggan.csv'), 'r');
        $header = true;
        $counter = 1;

        while (($row = fgetcsv($file, 1000, ',')) !== false) {
            if ($header) {
                $header = false;
                continue;
            }

            $nama = trim($row[0] ?? '');
            if (empty($nama)) continue;

            $username    = trim($row[1]);
            $password    = trim($row[2]);
            $serviceType = trim($row[3]);
            $namaPaket   = trim($row[4]);
            $harga       = (int) ($row[5] ?? 0);
            $status      = trim($row[6] ?? 'aktif');

            $paket = Package::firstOrCreate(
                [
                    'nama_paket' => $namaPaket,
                    'harga' => $harga,
                ],
                [
                    'service_type' => $serviceType,
                    'deskripsi' => $namaPaket . ($harga == 0 ? ' (Kelas CSR)' : ''),
                ]
            );

            Pelanggan::updateOrCreate(
                ['username' => $username],
                [
                    'nama_lengkap' => $nama,
                    'no_wa' => 'BELUM-ISI-' . $counter++,
                    'alamat' => '-',
                    'password' => Hash::make($password),
                    'hotspot_password' => $serviceType === 'hotspot' ? $password : null,
                    'service_type' => $serviceType,
                    'package_id' => $paket->id,
                    'tgl_jatuh_tempo' => 10,
                    'status' => $status,
                ]
            );
        }

        fclose($file);
    }
}
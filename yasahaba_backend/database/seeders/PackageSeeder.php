<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Package;

class PackageSeeder extends Seeder
{
    public function run()
    {
        $packages = [
            // --- PAKET PPPOE (RUMAHAN) ---
            [
                'nama_paket' => 'HM-Value',
                'tipe_layanan' => 'pppoe',
                'kecepatan_mbps' => 8, // dari 8M/8M
                'limit_device' => null,
                'harga' => 125000,
                'deskripsi' => 'Paket up to 8 Mbps. Aman buat keluarga kecil dan youtube. Max Perangkat 32 devices, ideal 3-4 devices.',
            ],
            [
                'nama_paket' => 'HM-Plus',
                'tipe_layanan' => 'pppoe',
                'kecepatan_mbps' => 12, // dari 12M/12M
                'limit_device' => null,
                'harga' => 150000,
                'deskripsi' => 'Paket kenceng up to 12 Mbps. Puas buat mabar dan netflix. Max Perangkat 32 devices, ideal 3-6 devices.',
            ],
            [
                'nama_paket' => 'HM-Pro',
                'tipe_layanan' => 'pppoe',
                'kecepatan_mbps' => 18, // dari 18M/18M
                'limit_device' => null,
                'harga' => 165000,
                'deskripsi' => 'Paket ngebut up to 18 Mbps. Keluarga besar no ngelag. Max Perangkat 32 devices, ideal 3-8 devices.',
            ],

            // --- PAKET HOTSPOT ---
            [
                'nama_paket' => 'HS-Basic-1',
                'tipe_layanan' => 'hotspot',
                'kecepatan_mbps' => null, 
                'limit_device' => 1,
                'harga' => 40000,
                'deskripsi' => 'Voucher bulanan khusus 1 device (HP/Laptop).',
            ],
            [
                'nama_paket' => 'HS-Value-2',
                'tipe_layanan' => 'hotspot',
                'kecepatan_mbps' => null,
                'limit_device' => 2,
                'harga' => 70000,
                'deskripsi' => 'Bisa dilogin barengan buat 2 device.',
            ],
            [
                'nama_paket' => 'HS-Plus-3',
                'tipe_layanan' => 'hotspot',
                'kecepatan_mbps' => null,
                'limit_device' => 3,
                'harga' => 100000,
                'deskripsi' => 'Bisa dilogin barengan buat 3 device.',
            ],
            [
                'nama_paket' => 'HS-Pro-4',
                'tipe_layanan' => 'hotspot',
                'kecepatan_mbps' => null,
                'limit_device' => 4,
                'harga' => 125000,
                'deskripsi' => 'Bisa dilogin barengan buat 4 device.',
            ],
            [
                'nama_paket' => 'HS-Max-5',
                'tipe_layanan' => 'hotspot',
                'kecepatan_mbps' => null,
                'limit_device' => 5,
                'harga' => 150000,
                'deskripsi' => 'Bisa dilogin barengan buat 5 device.',
            ],
        ];

        foreach ($packages as $paket) {
            Package::create($paket);
        }
    }
}

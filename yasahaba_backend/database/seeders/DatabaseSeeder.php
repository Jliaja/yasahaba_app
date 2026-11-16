<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Panggil PackageSeeder biar ikut di-seed!
        $this->call([
            PackageSeeder::class,
            PelangganSeeder::class,
        ]);

        // 2. Seed User Akun
        User::factory()->create([
            'name' => 'Pemilik ISP',
            'email' => 'pemilik@example.com',
            'password' => Hash::make('password123'),
            'role' => 'pemilik',
            'email_verified_at' => now(),
        ]);

        User::factory()->create([
            'name' => 'Petugas Penagih',
            'email' => 'penagih@example.com',
            'password' => Hash::make('password123'),
            'role' => 'penagih',
            'email_verified_at' => now(),
        ]);

        User::factory()->create([
            'name' => 'Pelanggan Setia',
            'email' => 'pelanggan@example.com',
            'password' => Hash::make('password123'),
            'role' => 'pelanggan',
            'email_verified_at' => now(),
        ]);
    }
}
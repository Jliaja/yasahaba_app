<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bills', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pelanggan_id')->constrained('pelanggan')->onDelete('cascade');
            
            // 👇 Tambahkan kolom penagih_id (relasi ke tabel users, nullable karena sebelum ditagih/lunas bisa kosong)
            $table->foreignId('penagih_id')->nullable()->constrained('users')->onDelete('set null');
            
            $table->integer('total_tagihan');
            $table->string('periode');
            $table->date('jatuh_tempo');
            $table->enum('status', ['lunas', 'belum_dibayar'])->default('belum_dibayar');
            
            // 👇 Tambahkan metode_bayar & keterangan_kendala sesuai query di PenagihController
            $table->string('metode_bayar')->nullable(); // contoh: 'cash', 'transfer', 'qris'
            $table->text('keterangan_kendala')->nullable();
            
            $table->timestamps();
        });
    
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bills');
    }
};

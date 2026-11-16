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
        Schema::create('packages', function (Blueprint $table) {
    $table->id();
    $table->string('nama_paket'); 
    $table->enum('tipe_layanan', ['pppoe', 'hotspot']); // pisahin jenisnya
    $table->integer('kecepatan_mbps')->nullable(); // buat pppoe
    $table->integer('limit_device')->nullable(); // buat hotspot
    $table->decimal('harga', 10, 2); 
    $table->text('deskripsi')->nullable();
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('packages');
    }
};

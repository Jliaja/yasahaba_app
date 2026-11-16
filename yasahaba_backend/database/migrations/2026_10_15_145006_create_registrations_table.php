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
        Schema::create('registrations', function (Blueprint $table) {
    $table->id();
    $table->string('nama_lengkap');
    $table->string('no_wa');
    $table->text('alamat_pemasangan');
    $table->foreignId('package_id')->constrained('packages');
    $table->enum('status', ['pending', 'diproses', 'aktif', 'ditolak'])->default('pending');
    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registrations');
    }
};

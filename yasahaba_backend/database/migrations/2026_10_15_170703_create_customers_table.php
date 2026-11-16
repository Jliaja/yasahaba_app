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
        Schema::create('pelanggan', function (Blueprint $table) {
            $table->id();
            $table->string('no_wa')->unique(); 
            $table->string('nama_lengkap');
            $table->text('alamat');
            // Foreign key ke tabel packages (packages harus dibuat lebih dulu)
            $table->foreignId('package_id')->constrained('packages')->onDelete('cascade');
            $table->string('ip_address')->nullable(); 
            $table->enum('status', ['aktif', 'isolir', 'nonaktif'])->default('aktif');
            $table->string('api_token', 80)->unique()->nullable()->default(null);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pelanggan');
    }
};
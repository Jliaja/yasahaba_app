<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Update tabel pelanggan
        Schema::table('pelanggan', function (Blueprint $table) {
            if (!Schema::hasColumn('pelanggan', 'username')) {
                $table->string('username')->nullable()->unique()->after('nama_lengkap');
            }
            if (!Schema::hasColumn('pelanggan', 'password')) {
                $table->string('password')->nullable()->after('username');
            }
            if (!Schema::hasColumn('pelanggan', 'hotspot_password')) {
                $table->string('hotspot_password')->nullable()->after('password');
            }
            if (!Schema::hasColumn('pelanggan', 'nik')) {
                $table->string('nik', 20)->nullable()->after('nama_lengkap');
            }
            if (!Schema::hasColumn('pelanggan', 'email')) {
                $table->string('email')->nullable()->after('nik');
            }
            if (!Schema::hasColumn('pelanggan', 'foto_ktp')) {
                $table->string('foto_ktp')->nullable()->after('email');
            }
            if (!Schema::hasColumn('pelanggan', 'service_type')) {
                $table->string('service_type', 20)->default('pppoe')->after('package_id');
            }
            if (!Schema::hasColumn('pelanggan', 'tgl_jatuh_tempo')) {
                $table->integer('tgl_jatuh_tempo')->default(10)->after('service_type');
            }
            if (!Schema::hasColumn('pelanggan', 'active_devices')) {
                $table->integer('active_devices')->default(1)->after('tgl_jatuh_tempo');
            }
            if (!Schema::hasColumn('pelanggan', 'max_devices')) {
                $table->integer('max_devices')->default(2)->after('active_devices');
            }
        });

        // 2. Update tabel packages
        if (Schema::hasTable('packages')) {
            Schema::table('packages', function (Blueprint $table) {
                if (!Schema::hasColumn('packages', 'service_type')) {
                    $table->string('service_type', 20)->default('pppoe')->after('nama_paket');
                }
                if (!Schema::hasColumn('packages', 'deskripsi')) {
                    $table->string('deskripsi')->nullable()->after('harga');
                }
            });
        }

        // 3. Update tabel bills
        if (Schema::hasTable('bills')) {
            Schema::table('bills', function (Blueprint $table) {
                if (!Schema::hasColumn('bills', 'bukti_transfer')) {
                    $table->string('bukti_transfer')->nullable()->after('metode_bayar');
                }
                if (!Schema::hasColumn('bills', 'settlement_id')) {
                    $table->unsignedBigInteger('settlement_id')->nullable()->after('penagih_id');
                }
            });
        }

        // 4. Update tabel tickets
        if (Schema::hasTable('tickets')) {
            Schema::table('tickets', function (Blueprint $table) {
                if (!Schema::hasColumn('tickets', 'foto_router')) {
                    $table->string('foto_router')->nullable()->after('deskripsi');
                }
            });
        }

        // 5. Update tabel users (pastikan ada kolom role)
        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'role')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('role', 20)->default('owner')->after('password');
            });
        }

        // 6. Buat tabel pengajuan ubah paket
        if (!Schema::hasTable('package_change_requests')) {
            Schema::create('package_change_requests', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('pelanggan_id');
                $table->unsignedBigInteger('paket_lama_id')->nullable();
                $table->unsignedBigInteger('paket_baru_id');
                $table->string('diajukan_oleh')->nullable();
                $table->text('catatan')->nullable();
                $table->string('status', 20)->default('pending');
                $table->timestamps();
            });
        }

        // 7. Buat tabel setoran penagih
        if (!Schema::hasTable('collector_settlements')) {
            Schema::create('collector_settlements', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('penagih_id');
                $table->decimal('nominal', 12, 2);
                $table->text('catatan')->nullable();
                $table->string('status', 20)->default('pending');
                $table->timestamps();
            });
        }

        // 8. Buat tabel knowledge base AI & broadcast gangguan
        if (!Schema::hasTable('ai_settings')) {
            Schema::create('ai_settings', function (Blueprint $table) {
                $table->id();
                $table->string('key')->unique();
                $table->longText('value')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('broadcasts')) {
            Schema::create('broadcasts', function (Blueprint $table) {
                $table->id();
                $table->string('judul');
                $table->text('pesan');
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        //
    }
};
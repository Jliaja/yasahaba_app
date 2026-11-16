<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\PenagihController;
use App\Http\Controllers\Api\PemilikController;

// ==========================================
// 1. PUBLIC AUTH & EXPORT (TANPA TOKEN)
// ==========================================
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password/send-otp', [AuthController::class, 'sendOtpEmail']);
Route::post('/forgot-password/reset', [AuthController::class, 'resetPasswordWithOtp']);

// Export CSV dibuka via browser HP oleh Pemilik
Route::get('/owner/export-pelanggan-isp', [PemilikController::class, 'exportPelangganIsp']);

// ==========================================
// 2. PROTECTED ROUTES (WAJIB TOKEN SANCTUM)
// ==========================================
Route::middleware('auth:sanctum')->group(function () {

    // Profil & Keamanan Semua Aktor
    Route::post('/change-password', [AuthController::class, 'changePassword']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // ------------------------------------------
    // A. PELANGGAN
    // ------------------------------------------
    Route::prefix('pelanggan')->group(function () {
        Route::post('/onboarding-ktp', [CustomerController::class, 'onboardingKtp']);
        Route::get('/dashboard', [CustomerController::class, 'dashboard']);
        Route::post('/hotspot/reset-session', [CustomerController::class, 'resetHotspotSession']);
        Route::get('/tagihan', [CustomerController::class, 'tagihan']);
        Route::post('/tagihan/{id}/upload-bukti', [CustomerController::class, 'uploadBuktiTransfer']);
        Route::get('/paket', [CustomerController::class, 'getDaftarPaket']);
        Route::post('/ubah-paket', [CustomerController::class, 'ajukanUbahPaket']);
        Route::post('/ask-ai', [CustomerController::class, 'askAi']);
        Route::post('/tiket-gangguan', [CustomerController::class, 'submitTiket']);
    });

    // ------------------------------------------
    // B. PENAGIH
    // ------------------------------------------
    Route::prefix('penagih')->group(function () {
        Route::get('/dashboard', [PenagihController::class, 'dashboard']);
        Route::post('/tagihan/{tagihanId}/terima-tunai', [PenagihController::class, 'terimaTunai']);
        Route::get('/paket', [PenagihController::class, 'getDaftarPaket']);
        Route::post('/delegasi/ubah-paket', [PenagihController::class, 'delegasiUbahPaket']);
        Route::post('/delegasi/tiket-gangguan', [PenagihController::class, 'delegasiTiketGangguan']);
        Route::get('/setoran', [PenagihController::class, 'getRekapSetoran']);
        Route::post('/setoran/ajukan', [PenagihController::class, 'ajukanSetoran']);
    });

    // ------------------------------------------
    // C. PEMILIK (OWNER)
    // ------------------------------------------
    Route::prefix('owner')->group(function () {
        Route::get('/dashboard', [PemilikController::class, 'dashboard']);
        Route::get('/paket', [PemilikController::class, 'getDaftarPaket']);
        Route::post('/paket', [PemilikController::class, 'tambahPaket']);
        Route::post('/users', [PemilikController::class, 'buatAkunUser']);
        Route::post('/tagihan/generate', [PemilikController::class, 'generateTagihanBulanan']);
        Route::get('/tagihan/pending', [PemilikController::class, 'getAntreanTransferPending']);
        Route::post('/tagihan/{id}/verifikasi', [PemilikController::class, 'verifikasiTransfer']);
        Route::get('/setoran/pending', [PemilikController::class, 'getAntreanSetoranPenagih']);
        Route::post('/setoran/{id}/validasi', [PemilikController::class, 'validasiSetoranPenagih']);
        Route::get('/ubah-paket', [PemilikController::class, 'getPengajuanUbahPaket']);
        Route::post('/ubah-paket/{id}/proses', [PemilikController::class, 'prosesUbahPaket']);
        Route::get('/tiket-gangguan', [PemilikController::class, 'getTiketGangguan']);
        Route::post('/tiket-gangguan/{id}/status', [PemilikController::class, 'updateStatusTiket']);
        Route::get('/ai-knowledge', [PemilikController::class, 'getAiKnowledge']);
        Route::post('/ai-knowledge', [PemilikController::class, 'saveAiKnowledge']);
        Route::post('/broadcast', [PemilikController::class, 'kirimBroadcastGangguan']);
        Route::get('/mikrotik/status', [PemilikController::class, 'getMikrotikStatus']);
        Route::post('/mikrotik/sync', [PemilikController::class, 'syncMikrotikUsers']);
    });
});
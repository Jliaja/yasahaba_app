<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PemasaranController;
use App\Http\Controllers\PemilikController;
use App\Http\Controllers\WebAuthController;

/*
|--------------------------------------------------------------------------
| Public Routes (Landing Page & Pendaftaran)
|--------------------------------------------------------------------------
*/
Route::get('/', [PemasaranController::class, 'index'])->name('pemasaran.index');

Route::post('/daftar', [PemasaranController::class, 'daftar'])
    ->name('pemasaran.daftar')
    ->middleware('throttle:5,1');

/*
|--------------------------------------------------------------------------
| Auth Routes
|--------------------------------------------------------------------------
*/
Route::get('/login', [WebAuthController::class, 'showLogin'])->name('login');
Route::post('/login', [WebAuthController::class, 'prosesLogin'])->name('login.proses');
Route::post('/logout', [WebAuthController::class, 'logout'])->name('logout');

/*
|--------------------------------------------------------------------------
| Pemilik Routes (Protected Area)
|--------------------------------------------------------------------------
*/
Route::middleware('auth')->prefix('pemilik')->name('pemilik.')->group(function () {
    Route::get('/', [PemilikController::class, 'index'])->name('index');
    Route::post('/acc-pendaftaran/{id}', [PemilikController::class, 'accPendaftaran'])->name('acc');
    Route::post('/buka-isolir-manual/{id}', [PemilikController::class, 'bukaIsolirManual'])->name('bukaIsolir');
    Route::post('/broadcast-wa', [PemilikController::class, 'broadcastWa'])->name('broadcast');
});
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Pelanggan;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Cache;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'password' => 'required'
        ]);

        // 1. Cek Owner / Penagih di tabel users
        $user = User::where('email', $request->username)
                    ->orWhere('name', $request->username)
                    ->first();

        if ($user && Hash::check($request->password, $user->password)) {
            $role = strtolower(trim($user->role ?? 'owner'));
            if (in_array($role, ['pemilik', 'admin', 'owner'])) {
                $role = 'owner';
            }

            $token = $user->createToken('auth_token', [$role])->plainTextToken;

            return response()->json([
                'status' => 'success',
                'message' => 'Login internal sukses',
                'actor' => $role,
                'token' => $token,
                'is_profile_completed' => true,
                'profil' => $user
            ], 200);
        }

        // 2. Cek Pelanggan di tabel pelanggan
        $pelanggan = Pelanggan::where('username', $request->username)
                              ->orWhere('nama_lengkap', $request->username)
                              ->orWhere('email', $request->username)
                              ->orWhere('no_wa', $request->username)
                              ->first();

        if ($pelanggan && Hash::check($request->password, $pelanggan->password)) {
            $token = $pelanggan->createToken('auth_token', ['pelanggan'])->plainTextToken;
            $isCompleted = !empty($pelanggan->nik) && !empty($pelanggan->email) && !empty($pelanggan->foto_ktp);

            return response()->json([
                'status' => 'success',
                'message' => 'Login pelanggan sukses',
                'actor' => 'pelanggan',
                'token' => $token,
                'is_profile_completed' => $isCompleted,
                'profil' => $pelanggan
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'message' => 'Username atau password salah!'
        ], 401);
    }

    public function sendOtpEmail(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();
        $pelanggan = Pelanggan::where('email', $request->email)->first();

        if (!$user && !$pelanggan) {
            return response()->json(['status' => 'error', 'message' => 'Email tidak terdaftar'], 404);
        }

        $otp = rand(100000, 999999);
        Cache::put('otp_reset_' . $request->email, $otp, now()->addMinutes(10));

        Mail::raw("Kode OTP Reset Password Yasahaba WiFi Anda adalah: {$otp}. Berlaku selama 10 menit.", function ($msg) use ($request) {
            $msg->to($request->email)->subject('Kode OTP Reset Password - Yasahaba WiFi');
        });

        return response()->json(['status' => 'success', 'message' => 'OTP terkirim ke email']);
    }

    public function resetPasswordWithOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required',
            'password' => 'required|min:6'
        ]);

        $cachedOtp = Cache::get('otp_reset_' . $request->email);
        if (!$cachedOtp || $cachedOtp != $request->otp) {
            return response()->json(['status' => 'error', 'message' => 'Kode OTP salah atau kadaluarsa'], 400);
        }

        $user = User::where('email', $request->email)->first();
        if ($user) {
            $user->password = Hash::make($request->password);
            $user->save();
        } else {
            $pelanggan = Pelanggan::where('email', $request->email)->first();
            if ($pelanggan) {
                $pelanggan->password = Hash::make($request->password);
                $pelanggan->save();
            }
        }

        Cache::forget('otp_reset_' . $request->email);
        return response()->json(['status' => 'success', 'message' => 'Password berhasil direset']);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required',
            'new_password' => 'required|min:6'
        ]);

        $authUser = $request->user();
        if (!Hash::check($request->old_password, $authUser->password)) {
            return response()->json(['status' => 'error', 'message' => 'Password lama salah'], 400);
        }

        $authUser->password = Hash::make($request->new_password);
        $authUser->save();

        return response()->json(['status' => 'success', 'message' => 'Password berhasil diubah']);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['status' => 'success', 'message' => 'Berhasil logout']);
    }
}
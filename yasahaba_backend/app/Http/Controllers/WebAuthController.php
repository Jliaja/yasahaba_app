<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WebAuthController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    public function prosesLogin(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if (Auth::attempt($credentials)) {
            // cek kalo yang login ternyata penagih, tendang ke luar
            if (Auth::user()->role !== 'pemilik') {
                Auth::logout();
                return back()->withErrors(['email' => 'AKSES DITOLAK ROLE KHUSUS DIPERLUKAN']);
            }

            $request->session()->regenerate();
            return redirect()->route('pemilik.index');
        }

        return back()->withErrors([
            'email' => 'Email atau password salah.',
        ])->onlyInput('email');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/');
    }
}
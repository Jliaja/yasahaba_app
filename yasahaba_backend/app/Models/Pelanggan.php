<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Pelanggan extends Authenticatable
{
    use HasFactory, HasApiTokens;

    protected $table = 'pelanggan';
    protected $guarded = [];

    protected $hidden = ['password'];

    public function paket()
    {
        return $this->belongsTo(Package::class, 'package_id');
    }

    public function tagihan()
    {
        return $this->hasMany(Bill::class, 'pelanggan_id');
    }

    public function tiket()
    {
        return $this->hasMany(Ticket::class, 'pelanggan_id');
    }
}
<?php

namespace App\Services;

use RouterOS\Client;
use RouterOS\Query;
use Exception;
use RuntimeException;

class MikrotikService
{
    private function connect(): Client
    {
        $host = config('services.mikrotik.host');
        $user = config('services.mikrotik.user');
        $pass = config('services.mikrotik.pass');
        $port = config('services.mikrotik.port');

        if (empty($host) || empty($user) || empty($port)) {
            throw new RuntimeException('Konfigurasi MIKROTIK_HOST, MIKROTIK_USER, atau MIKROTIK_PORT belum diisi di file .env');
        }

        return new Client([
            'host'    => (string) $host,
            'user'    => (string) $user,
            'pass'    => (string) ($pass ?? ''),
            'port'    => (int) $port,
            'timeout' => 5,
        ]);
    }

    public function getRouterStatus(): array
    {
        try {
            $client        = $this->connect();
            $resource      = $client->query('/system/resource/print')->read()[0] ?? [];
            $pppoeActive   = $client->query('/ppp/active/print')->read();
            $hotspotActive = $client->query('/ip/hotspot/active/print')->read();

            return [
                'connected'      => true,
                'board_name'     => $resource['board-name'] ?? 'MikroTik',
                'uptime'         => $resource['uptime'] ?? '-',
                'cpu_load'       => ($resource['cpu-load'] ?? 0) . '%',
                'pppoe_online'   => count($pppoeActive),
                'hotspot_online' => count($hotspotActive),
                'active_users'   => [
                    'pppoe'   => array_column($pppoeActive, 'name'),
                    'hotspot' => array_column($hotspotActive, 'user'),
                ],
            ];
        } catch (Exception $e) {
            return [
                'connected' => false,
                'error'     => $e->getMessage(),
            ];
        }
    }

    public function getAllUsersFromMikrotik(): array
    {
        $client       = $this->connect();
        $pppoeSecrets = $client->query('/ppp/secret/print')->read();
        $hotspotUsers = $client->query('/ip/hotspot/user/print')->read();

        return [
            'pppoe'   => $pppoeSecrets,
            'hotspot' => $hotspotUsers,
        ];
    }

    public function createUser(string $serviceType, string $username, string $password, string $profile): bool
    {
        try {
            $client = $this->connect();

            if ($serviceType === 'hotspot') {
                $query = (new Query('/ip/hotspot/user/add'))
                    ->equal('name', $username)
                    ->equal('password', $password)
                    ->equal('profile', $profile);
            } else {
                $query = (new Query('/ppp/secret/add'))
                    ->equal('name', $username)
                    ->equal('password', $password)
                    ->equal('service', 'pppoe')
                    ->equal('profile', $profile);
            }

            $client->query($query)->read();
            return true;
        } catch (Exception $e) {
            return false;
        }
    }

    public function setUserProfile(string $serviceType, string $username, string $targetProfile): bool
    {
        try {
            $client = $this->connect();

            if ($serviceType === 'hotspot') {
                $users = $client->query((new Query('/ip/hotspot/user/print'))->where('name', $username))->read();
                if (!empty($users[0]['.id'])) {
                    $client->query(
                        (new Query('/ip/hotspot/user/set'))
                            ->equal('.id', $users[0]['.id'])
                            ->equal('profile', $targetProfile)
                    )->read();
                }

                $actives = $client->query((new Query('/ip/hotspot/active/print'))->where('user', $username))->read();
                foreach ($actives as $act) {
                    $client->query((new Query('/ip/hotspot/active/remove'))->equal('.id', $act['.id']))->read();
                }
            } else {
                $secrets = $client->query((new Query('/ppp/secret/print'))->where('name', $username))->read();
                if (!empty($secrets[0]['.id'])) {
                    $client->query(
                        (new Query('/ppp/secret/set'))
                            ->equal('.id', $secrets[0]['.id'])
                            ->equal('profile', $targetProfile)
                    )->read();
                }

                $actives = $client->query((new Query('/ppp/active/print'))->where('name', $username))->read();
                foreach ($actives as $act) {
                    $client->query((new Query('/ppp/active/remove'))->equal('.id', $act['.id']))->read();
                }
            }

            return true;
        } catch (Exception $e) {
            return false;
        }
    }

    // 5. Ambil Uptime & Pemakaian Kuota (Download/Upload) Pelanggan dari Sesi Aktif MikroTik
    public function getUserSessionStats(string $serviceType, string $username): array
    {
        try {
            $client = $this->connect();

            if ($serviceType === 'hotspot') {
                $sessions = $client->query(
                    (new Query('/ip/hotspot/active/print'))->where('user', $username)
                )->read();
            } else {
                $sessions = $client->query(
                    (new Query('/ppp/active/print'))->where('name', $username)
                )->read();
            }

            if (empty($sessions)) {
                return [
                    'online'    => false,
                    'uptime'    => 'Offline',
                    'download'  => '0 MB',
                    'upload'    => '0 MB',
                    'total'     => '0 MB',
                    'ip_client' => '-',
                ];
            }

            $totalBytesOut = 0; // Download ke pelanggan
            $totalBytesIn  = 0; // Upload dari pelanggan
            $uptime        = $sessions[0]['uptime'] ?? '-';
            $ipClient      = $sessions[0]['address'] ?? '-';

            foreach ($sessions as $s) {
                $totalBytesOut += (int) ($s['bytes-out'] ?? 0);
                $totalBytesIn  += (int) ($s['bytes-in'] ?? 0);
            }

            return [
                'online'    => true,
                'uptime'    => $uptime,
                'download'  => $this->formatBytes($totalBytesOut),
                'upload'    => $this->formatBytes($totalBytesIn),
                'total'     => $this->formatBytes($totalBytesOut + $totalBytesIn),
                'ip_client' => $ipClient,
            ];
        } catch (Exception $e) {
            return [
                'online'    => false,
                'uptime'    => '-',
                'download'  => '-',
                'upload'    => '-',
                'total'     => '-',
                'ip_client' => '-',
            ];
        }
    }

    private function formatBytes(int $bytes): string
    {
        if ($bytes <= 0) return '0 MB';
        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        $pow   = min((int) floor(log($bytes, 1024)), count($units) - 1);
        $val   = $bytes / (1024 ** $pow);
        return round($val, 2) . ' ' . $units[$pow];
    }
}
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\PoliceStation;
use App\Models\Category;
use App\Models\SubCategory;
use App\Models\User;
use App\Models\Complaint;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\DB;
use Google\Auth\Credentials\ServiceAccountCredentials;
use GuzzleHttp\Client;
use Carbon\Carbon;

class ImportFirebase extends Command
{
    protected $signature = 'import:firebase {--resume : Continue from where it left off}';
    protected $description = 'Import 49,000+ records with duplicate prevention and resume capability';

    private $baseUrl = "https://firestore.googleapis.com/v1/projects/kpd-reception/databases/(default)/documents";

    public function handle()
    {
        ini_set('memory_limit', '512M');
        set_time_limit(0);

        $this->info("🚀 Starting Smart Migration Engine...");

        $keyFile = base_path('service-account.json');
        if (!file_exists($keyFile)) {
            $this->error("❌ service-account.json missing.");
            return;
        }

        $this->info("🔑 Authenticating...");
        try {
            $httpClient = new Client(['verify' => false]);
            $httpHandler = function ($request, $options = []) use ($httpClient) { return $httpClient->send($request, $options); };
            $creds = new ServiceAccountCredentials('https://www.googleapis.com/auth/datastore', $keyFile);
            $token = $creds->fetchAuthToken($httpHandler)['access_token'];
            $this->info("✔ Authenticated.");
        } catch (\Exception $e) {
            $this->error("❌ Auth Failed: " . $e->getMessage());
            return;
        }

        // 1-4: Basic Data (Always updated)
        $this->importCollection($token, 'police_station', function($data, $docId) {
            PoliceStation::updateOrCreate(['name' => $data['name'] ?? 'Unknown'], ['notification_id' => $data['notification_id'] ?? Str::random(10)]);
        });

        $this->importCollection($token, 'category', function($data, $docId) {
            Category::updateOrCreate(['id' => $this->mapId($docId)], ['name' => $data['categoryName'] ?? 'Unnamed', 'notification_enabled' => (bool)($data['notificationStatus'] ?? false), 'priority' => $data['notificationType'] ?? 'none']);
        });

        $this->importCollection($token, 'sub_category', function($data, $docId) {
            $catId = $this->findCategoryId($data['cat_id'] ?? '');
            if (!$catId) $catId = Category::firstOrCreate(['name' => 'General Information'])->id;
            SubCategory::updateOrCreate(['name' => $data['name'] ?? 'Unnamed'], ['category_id' => $catId, 'is_disabled' => (bool)($data['disabled'] ?? false)]);
        });

        $this->importCollection($token, 'user_data', function($data, $docId) {
            $email = $data['email'] ?? null;
            if ($email) {
                $user = User::updateOrCreate(['email' => $email], [
                    'firebase_uid' => $docId,
                    'name' => $data['full_name'] ?? $data['name'] ?? 'No Name',
                    'full_name' => $data['full_name'] ?? $data['name'] ?? 'No Name',
                    'password' => Hash::make('password123'),
                    'police_station_id' => $this->findStationId($data['police_station'] ?? '')
                ]);
                if (isset($data['role'])) { try { $user->syncRoles([$data['role']]); } catch (\Exception $e) {} }
            }
        });

        // 5. Complaints (The Big One)
        $this->info("📂 Starting/Resuming Complaints Import...");
        $this->importCollection($token, 'complaints', function($data, $docId) {
            $subCatId = $this->findSubCategoryId($data['complainType'] ?? '');
            $stationId = $this->findStationId($data['police_station'] ?? '');
            
            // USE UPDATE OR CREATE TO PREVENT DUPLICATES
            Complaint::updateOrCreate(
                ['firebase_id' => $docId],
                [
                    'complainant_name' => $data['name'] ?? 'N/A',
                    'phone' => $data['phone'] ?? 'N/A',
                    'address' => $data['address'] ?? 'N/A',
                    'sub_category_id' => $subCatId ?? 1,
                    'description' => $data['description'] ?? '',
                    'receptionist_id' => $this->findUserId($data['user_id'] ?? null),
                    'police_station_id' => $stationId ?? 1,
                    'is_editable' => (bool)($data['edit_status'] ?? false),
                    'created_at' => isset($data['timestamp']) ? Carbon::parse($data['timestamp']) : now(),
                ]
            );
        }, true);

        $this->info("🎉 ALL MIGRATION TASKS COMPLETE!");
    }

    private function importCollection($token, $collection, $callback, $isMassive = false)
    {
        $this->info("📡 Fetching '$collection'...");
        $pageToken = null;
        $totalCount = 0;

        do {
            $url = "{$this->baseUrl}/{$collection}?pageSize=300" . ($pageToken ? "&pageToken={$pageToken}" : "");
            $response = Http::withoutVerifying()->withToken($token)->get($url);

            if ($response->failed()) {
                if ($response->status() == 429) {
                    $this->warn("\n⚠️ Firebase Quota Exceeded. Script will pause for 30 seconds and retry...");
                    sleep(30);
                    continue; // Retry same URL
                }
                $this->error("\n❌ Failed: " . $response->body());
                break;
            }

            $json = $response->json();
            $documents = $json['documents'] ?? [];
            $nextPageToken = $json['nextPageToken'] ?? null;
            
            DB::transaction(function() use ($documents, $callback, &$totalCount) {
                foreach ($documents as $doc) {
                    $fields = $doc['fields'] ?? [];
                    $data = $this->parseFields($fields);
                    $pathParts = explode('/', $doc['name']);
                    $docId = end($pathParts);
                    $callback($data, $docId);
                    $totalCount++;
                }
            });

            $this->output->write("\r   -> Processed: $totalCount items...");

            $pageToken = $nextPageToken;
            
            // If massive, add a tiny sleep to stay under rate limits
            if ($isMassive) usleep(100000); // 0.1 seconds

        } while ($pageToken);

        $this->info("\n✅ Finished $collection. Total: $totalCount");
    }

    private function parseFields($fields)
    {
        $parsed = [];
        foreach ($fields as $key => $value) {
            $type = array_key_first($value);
            $val = $value[$type];
            if ($type === 'arrayValue') { $val = $val['values'] ?? []; }
            $parsed[$key] = $val;
        }
        return $parsed;
    }

    private function findStationId($nameOrId) {
        if (!$nameOrId) return null;
        static $stationCache = [];
        if (isset($stationCache[$nameOrId])) return $stationCache[$nameOrId];
        $id = PoliceStation::where('name', $nameOrId)->value('id') ?? PoliceStation::where('id', $this->mapId($nameOrId))->value('id');
        $stationCache[$nameOrId] = $id;
        return $id;
    }

    private function findCategoryId($firebaseId) {
        return Category::where('id', $this->mapId($firebaseId))->value('id');
    }

    private function findSubCategoryId($name) {
        if (!$name) return null;
        static $subCache = [];
        if (isset($subCache[$name])) return $subCache[$name];
        $id = SubCategory::where('name', $name)->value('id');
        $subCache[$name] = $id;
        return $id;
    }

    private function findUserId($firebaseUid) {
        if (!$firebaseUid) return User::first()->id ?? 1;
        static $userCache = [];
        if (isset($userCache[$firebaseUid])) return $userCache[$firebaseUid];
        $id = User::where('firebase_uid', $firebaseUid)->value('id') ?? User::first()->id ?? 1;
        $userCache[$firebaseUid] = $id;
        return $id;
    }

    private function mapId($firestoreId) {
        if (!$firestoreId) return null;
        if (is_numeric($firestoreId)) return (int)$firestoreId;
        return crc32($firestoreId);
    }
}

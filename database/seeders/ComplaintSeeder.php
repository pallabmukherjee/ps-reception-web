<?php

namespace Database\Seeders;

use App\Models\Complaint;
use App\Models\PoliceStation;
use App\Models\SubCategory;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ComplaintSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $csvFiles = [
            'complaints.csv',
            'complaints (1).csv',
            'complaints (2).csv',
            'complaints (3).csv',
            'complaints (4).csv',
            'complaints (5).csv',
            'complaints (6).csv',
            'complaints (7).csv',
            'complaints (8).csv',
            'complaints (9).csv',
            'complaints (10).csv',
            'complaints (11).csv',
            'complaints (12).csv',
            'complaints (13).csv',
            'complaints (14).csv',
            'complaints (15).csv',
            'complaints (16).csv',
        ];

        // Cache subcategories and stations for performance
        $subCategories = SubCategory::all()->pluck('id', 'name')->toArray();
        $stations = PoliceStation::all()->pluck('id', 'name')->toArray();

        // Batch size for insertion
        $batchSize = 500;
        $complaints = [];

        foreach ($csvFiles as $file) {
            $filePath = base_path($file);
            if (!file_exists($filePath)) {
                $this->command->warn("File not found: {$file}");
                continue;
            }

            $this->command->info("Processing {$file}...");
            $handle = fopen($filePath, 'r');
            $header = fgetcsv($handle); // Skip header

            while (($data = fgetcsv($handle)) !== false) {
                if (count($data) < 9) continue;

                // Name,Phone,Address,Complain Type,Description,Police Station,Receptionist Name,Receptionist Mobile,Complain Register Time
                $complainantName = $data[0];
                $phone = $data[1];
                $address = $data[2];
                $complainType = $data[3];
                $description = $data[4];
                $stationName = $data[5];
                $receptionistName = $data[6];
                $receptionistMobile = $data[7];
                $registerTime = $data[8];

                $subCategoryId = $subCategories[$complainType] ?? null;
                $stationId = $stations[$stationName] ?? null;

                if (!$subCategoryId) {
                    $this->command->warn("SubCategory not found for type: '{$complainType}' in {$file}. Skipping row.");
                    continue;
                }

                if (!$stationId) {
                    $this->command->warn("Police Station not found for: '{$stationName}' in {$file}.");
                }

                // Attempt to parse date: 17/05/2026, 07:35 pm
                try {
                    $createdAt = Carbon::createFromFormat('d/m/Y, h:i a', $registerTime);
                } catch (\Exception $e) {
                    $createdAt = now();
                }

                $complaints[] = [
                    'complainant_name' => $complainantName,
                    'phone' => $phone,
                    'address' => $address,
                    'sub_category_id' => $subCategoryId,
                    'description' => $description,
                    'police_station_id' => $stationId,
                    'receptionist_name' => $receptionistName,
                    'receptionist_mobile' => $receptionistMobile,
                    'created_at' => $createdAt,
                    'updated_at' => $createdAt,
                ];

                if (count($complaints) >= $batchSize) {
                    Complaint::insert($complaints);
                    $complaints = [];
                }
            }
            fclose($handle);
        }

        if (count($complaints) > 0) {
            Complaint::insert($complaints);
        }

        $this->command->info("Complaint seeding completed.");
    }
}

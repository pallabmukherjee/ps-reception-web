<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Run RoleSeeder
        $this->call(RoleSeeder::class);

        // Create or Update Super Admin
        $superAdmin = \App\Models\User::updateOrCreate(
            ['email' => 'admin@kpd.com'],
            [
                'name' => 'Super Admin',
                'full_name' => 'Super Admin',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
            ]
        );

        // Assign super role for web guard
        if (!$superAdmin->hasRole('super', 'web')) {
            $superAdmin->assignRole('super');
        }

        // Seed Categories and Sub-categories
        $data = [
            'Normal' => [
                'Enquiry',
                'Report for GD',
                'Passport Related',
                'Character Antecedents',
                'Others',
            ],
            'Critical' => [
                'Accident',
                'Theft/Burglary',
                'Missing/Kidnapping',
                'Crime Against Women',
                'Violence/Clash',
                'Cyber Crime',
            ]
        ];

        foreach ($data as $catName => $subs) {
            $category = \App\Models\Category::firstOrCreate(['name' => $catName]);
            foreach ($subs as $subName) {
                \App\Models\SubCategory::firstOrCreate([
                    'category_id' => $category->id,
                    'name' => $subName
                ]);
            }
        }
    }
}

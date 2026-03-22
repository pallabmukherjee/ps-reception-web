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
        $superAdmin = User::updateOrCreate(
            ['email' => 'admin@kpd.com'],
            [
                'name' => 'Super Admin',
                'full_name' => 'Super Admin',
                'password' => Hash::make('password'),
            ]
        );

        // Assign super role for web guard
        if (!$superAdmin->hasRole('super', 'web')) {
            $superAdmin->assignRole('super');
        }
    }
}

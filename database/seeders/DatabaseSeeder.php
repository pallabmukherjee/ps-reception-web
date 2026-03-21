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
        // Create Roles safely
        $superRole = Role::firstOrCreate(['name' => 'super']);
        $userRole = Role::firstOrCreate(['name' => 'user']);
        $superiorRole = Role::firstOrCreate(['name' => 'superior']);

        // Create or Update Super Admin
        $admin = User::updateOrCreate(
            ['email' => 'admin@kpd.com'],
            [
                'name' => 'Super Admin',
                'full_name' => 'Super Admin',
                'password' => Hash::make('password'),
            ]
        );

        if (!$admin->hasRole('super')) {
            $admin->assignRole($superRole);
        }
    }
}

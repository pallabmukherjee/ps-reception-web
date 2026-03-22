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
        // Define guards
        $guards = ['web', 'api'];

        foreach ($guards as $guard) {
            Role::firstOrCreate(['name' => 'super', 'guard_name' => $guard]);
            Role::firstOrCreate(['name' => 'admin', 'guard_name' => $guard]);
            Role::firstOrCreate(['name' => 'superior', 'guard_name' => $guard]);
            Role::firstOrCreate(['name' => 'user', 'guard_name' => $guard]);
        }

        // Create or Update Super Admin
        $superAdmin = User::updateOrCreate(
            ['email' => 'admin@kpd.com'],
            [
                'name' => 'Super Admin',
                'full_name' => 'Super Admin',
                'password' => Hash::make('password'),
            ]
        );

        if (!$superAdmin->hasRole('super', 'web')) {
            $superAdmin->assignRole('super');
        }
    }
}

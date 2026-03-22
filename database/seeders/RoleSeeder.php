<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Truncate tables safely
        Schema::disableForeignKeyConstraints();
        DB::table('model_has_permissions')->truncate();
        DB::table('model_has_roles')->truncate();
        DB::table('role_has_permissions')->truncate();
        DB::table('permissions')->truncate();
        DB::table('roles')->truncate();
        Schema::enableForeignKeyConstraints();

        // Define guards - only web is needed
        $guards = ['web'];

        foreach ($guards as $guard) {
            Role::create(['name' => 'super', 'guard_name' => $guard]);
            Role::create(['name' => 'admin', 'guard_name' => $guard]);
            Role::create(['name' => 'superior', 'guard_name' => $guard]);
            Role::create(['name' => 'user', 'guard_name' => $guard]);
        }
        
        $this->command->info('Roles truncated and recreated successfully for all guards.');
    }
}

<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Green',
                'notification_enabled' => false,
                'priority' => 'LOW PRIORITY',
                'is_disabled' => false,
            ],
            [
                'name' => 'Red',
                'notification_enabled' => true,
                'priority' => 'HIGH PRIORITY',
                'is_disabled' => false,
            ],
        ];

        foreach ($categories as $category) {
            Category::updateOrCreate(['name' => $category['name']], $category);
        }
    }
}

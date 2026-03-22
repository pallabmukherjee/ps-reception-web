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
            'Green' => [
                'Male Missing (পুরুষ নিরুদ্দেশ)',
                'Passport Verification (পাসপোর্ট যাচাই)',
                'CA Verification',
                'Mob Linching (গণ পিটুনি)',
                'Permission - Political Rally/Festival/Fair/Idol immersion',
                'Arms License - New/Renewal (অস্ত্র ছাড়পত্র - নূতন/পুনর্নবিকরণ)',
                'Physical Assault(শারীরিক ভাবে আঘাত করা)',
                'Meeting with IO/Officer (অফিসারের সঙ্গে দেখা করা)',
                'Other Cyber Fraud - অন্যান্য সাইবার সংক্রান্ত প্রতারণা',
                'Money fraud - আর্থিক জালিয়াতি',
                'Other - অন্যান্য',
                'Mobile/SIM card missing - মোবাইল/সিম কার্ড হারানো',
                'Dacoity - ডাকাতি',
                'Hazira - হাজিরা',
                'Theft - চুরি',
                'Threat - হুমকি',
                'Documents missing (Addhar, Pan, Deed etc) - নথিপত্র হারানো',
                'Female Missing - মহিলা নিরুদ্দেশ',
                'Domestic violence - পারিবারিক হিংসা',
                'Land dispute - জমি সংক্রান্ত সমস্যা',
                'Political clash - রাজনৈতিক সংঘাত',
            ],
            'Red' => [
                'Minor Girl / Boy missing - শিশু কন্যা / পুত্র নিখোঁজ',
                'Dowry death - পণ এর জন্য হত্যা',
                'Murder - খুন',
                'Sexual harrassment - যৌন নির্যাতন',
                'Communal clash - সাম্প্রদায়িক অশান্তি',
                'Acid attack - অ্যাসিড হামলা',
                'Rape/Gang Rape - ধর্ষণ/গণ ধর্ষণ',
                'POCSO - পকসো',
            ]
        ];

        // Clear existing sub-categories and categories to avoid duplicates and remove old ones
        \App\Models\SubCategory::truncate();
        \App\Models\Category::truncate();

        foreach ($data as $catName => $subs) {
            $category = \App\Models\Category::create(['name' => $catName]);
            foreach ($subs as $subName) {
                $isDisabled = ($subName === 'Other - অন্যান্য');
                \App\Models\SubCategory::create([
                    'category_id' => $category->id,
                    'name' => $subName,
                    'is_disabled' => $isDisabled
                ]);
            }
        }
    }
}

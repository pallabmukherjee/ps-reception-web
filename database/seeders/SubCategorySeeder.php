<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\SubCategory;
use Illuminate\Database\Seeder;

class SubCategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $green = Category::where('name', 'Green')->first();
        $red = Category::where('name', 'Red')->first();

        if (!$green || !$red) {
            $this->command->error('Categories Green and Red must exist before seeding SubCategories.');
            return;
        }

        $subCategories = [
            // Green Category
            ['name' => 'Male Missing (পুরুষ নিরুদ্দেশ)', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Passport Verification (পাসপোর্ট যাচাই)', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'CA Verification', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Mob Linching (গণ পিটুনি)', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Permission - Political Rally/Festival/Fair/Idol immersion', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Arms License - New/Renewal (অস্ত্র ছাড়পত্র - নতুন/পুনর্নবিকরণ)', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Physical Assault (শারীরিক ভাবে আঘাত করা)', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Meeting with IO/Officer (অফিসারের সঙ্গে দেখা করা)', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Other Cyber Fraud - অন্যান্য সাইবার সংক্রান্ত প্রতারণা', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Money fraud - আর্থিক জালিয়াতি', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Other - অন্যান্য', 'category_id' => $green->id, 'is_disabled' => true],
            ['name' => 'Mobile/SIM card missing - মোবাইল/সিম কার্ড হারানো', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Dacoity - ডাকাতি', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Hazira - হাজিরা', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Theft - চুরি', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Threat - হুমকি', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Documents missing (Addhar, Pan, Deed etc) - নথিপত্র হারানো', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Female Missing - মহিলা নিরুদ্দেশ', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Domestic violence - পারিবারিক হিংসা', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Land dispute - জমি সংক্রান্ত সমস্যা', 'category_id' => $green->id, 'is_disabled' => false],
            ['name' => 'Political clash - রাজনৈতিক সংঘাত', 'category_id' => $green->id, 'is_disabled' => false],
            
            // Red Category
            ['name' => 'Minor Girl / Boy missing - শিশু কন্যা / পুত্র নিখোঁজ', 'category_id' => $red->id, 'is_disabled' => false],
            ['name' => 'Dowry death - পণ এর জন্য হত্যা', 'category_id' => $red->id, 'is_disabled' => false],
            ['name' => 'Murder - খুন', 'category_id' => $red->id, 'is_disabled' => false],
            ['name' => 'Sexual harrassment - যৌন নির্যাতন', 'category_id' => $red->id, 'is_disabled' => false],
            ['name' => 'Communal clash - সাম্প্রদায়িক অশান্তি', 'category_id' => $red->id, 'is_disabled' => false],
            ['name' => 'Acid attack - অ্যাসিড হামলা', 'category_id' => $red->id, 'is_disabled' => false],
            ['name' => 'Rape/Gang Rape - ধর্ষণ/গণ ধর্ষণ', 'category_id' => $red->id, 'is_disabled' => false],
            ['name' => 'POCSO - পকসো', 'category_id' => $red->id, 'is_disabled' => false],
        ];

        foreach ($subCategories as $subCategory) {
            SubCategory::updateOrCreate(['name' => $subCategory['name']], $subCategory);
        }
    }
}

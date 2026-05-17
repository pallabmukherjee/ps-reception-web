<?php

namespace Database\Seeders;

use App\Models\PoliceStation;
use Illuminate\Database\Seeder;

class PoliceStationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $stations = [
            'Debogram ROP',
            'Juranpur ROP',
            'Mira ROP',
            'Thanarpara',
            'Murutia',
            'Hogalberia',
            'Krimpur',
            'Bhimpur',
            'Chapra',
            'Nabadwip',
            'Krishnaganj',
            'Nakashipara',
            'Palashipara',
            'Test PS',
            'Tehatta PS',
            'Kotwali PS',
            'Dhubulia PS',
            'Kaliganj PS',
        ];

        foreach ($stations as $station) {
            PoliceStation::updateOrCreate(['name' => $station]);
        }
    }
}

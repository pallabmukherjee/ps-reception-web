<?php

namespace Database\Seeders;

use App\Models\PoliceStation;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $password = Hash::make('password');

        $users = [
            ['email' => 'kaliganjps@gmail.com', 'full_name' => 'Kaliganj PS', 'phone_number' => '9876543210', 'address' => 'Kaliganj', 'role' => 'admin', 'station' => 'Kaliganj PS'],
            ['email' => 'icnakashipara@gmail.com', 'full_name' => 'IC Nakashipara', 'phone_number' => '9147888299', 'address' => 'Nakashipara', 'role' => 'superior', 'station' => 'Nakashipara'],
            ['email' => 'debogramrop@gmail.com', 'full_name' => 'Debogram ROP', 'phone_number' => '9147888310', 'address' => 'Debogram', 'role' => 'admin', 'station' => 'Debogram ROP'],
            ['email' => 'murutiaps@gmail.com', 'full_name' => 'Murutia PS', 'phone_number' => '9999999999', 'address' => 'Murutia', 'role' => 'admin', 'station' => 'Murutia'],
            ['email' => 'joy.sikdar.in@gmail.com', 'full_name' => 'Test Admin', 'phone_number' => '85858585', 'address' => 'test', 'role' => 'admin', 'station' => 'Test PS'],
            ['email' => 'chapraps@gmail.com', 'full_name' => 'Chapra PS', 'phone_number' => '9999999999', 'address' => 'Chapra', 'role' => 'admin', 'station' => 'Chapra'],
            ['email' => 'ickaliganj@gmail.com', 'full_name' => 'IC Kaliganj', 'phone_number' => '9147888298', 'address' => 'Kaliganj', 'role' => 'superior', 'station' => 'Kaliganj PS'],
            ['email' => 'ochogalberia@gmail.com', 'full_name' => 'OC Hogalberia', 'phone_number' => '9999999999', 'address' => 'Hogalberia', 'role' => 'superior', 'station' => 'Hogalberia'],
            ['email' => 'mirarop@gmail.com', 'full_name' => 'Mira ROP', 'phone_number' => '9147888308', 'address' => 'Mira ROP', 'role' => 'admin', 'station' => 'Mira ROP'],
            ['email' => 'kotwalips@gmail.com', 'full_name' => 'Kotwali PS', 'phone_number' => '9876543210', 'address' => 'Krishnanagar, Nadia', 'role' => 'admin', 'station' => 'Kotwali PS'],
            ['email' => 'ickarimpur@gmail.com', 'full_name' => 'IC Karimpur', 'phone_number' => '9147888302', 'address' => 'Karimpur', 'role' => 'superior', 'station' => 'Krimpur'],
            ['email' => 'karimpurps@gmail.com', 'full_name' => 'Karimpur PS', 'phone_number' => '9999999999', 'address' => 'Karimpur', 'role' => 'admin', 'station' => 'Krimpur'],
            ['email' => 'ocdhubulia@gmail.com', 'full_name' => 'OC Dhubulia', 'phone_number' => '9999999999', 'address' => 'Dhubulia', 'role' => 'superior', 'station' => 'Dhubulia PS'],
            ['email' => 'icjuranpur@gmail.com', 'full_name' => 'IC Juranpur', 'phone_number' => '9147888279', 'address' => 'Juranpur', 'role' => 'superior', 'station' => 'Juranpur ROP'],
            ['email' => 'palashiparaps@gmail.com', 'full_name' => 'Palashipara', 'phone_number' => '9999999999', 'address' => 'Palashipara', 'role' => 'admin', 'station' => 'Palashipara'],
            ['email' => 'sadikul.islam92@gmail.com', 'full_name' => 'Sadikul Islam', 'phone_number' => '7047303787', 'address' => 'Mira Bazar ROP', 'role' => 'user', 'station' => null],
            ['email' => 'testps@gmail.com', 'full_name' => 'Test Superior', 'phone_number' => '9999999999', 'address' => 'fdfd', 'role' => 'admin', 'station' => 'Test PS'],
            ['email' => 'ictehatta@gmail.com', 'full_name' => 'IC Tehatta', 'phone_number' => '9147888296', 'address' => 'Tehatta', 'role' => 'superior', 'station' => 'Tehatta PS'],
            ['email' => 'dhubuliaps@gmail.com', 'full_name' => 'OC Dhubulia', 'phone_number' => '9889898789', 'address' => 'Dhubulia', 'role' => 'admin', 'station' => 'Dhubulia PS'],
            ['email' => 'thanarparaps@gmail.com', 'full_name' => 'Thanarpara PS', 'phone_number' => '9999999999', 'address' => 'Thanarpara', 'role' => 'admin', 'station' => 'Thanarpara'],
            ['email' => 'ictest@gmail.com', 'full_name' => 'IC Test', 'phone_number' => '878788799287', 'address' => 'gagha', 'role' => 'superior', 'station' => 'Test PS'],
            ['email' => 'octhanarpara@gmail.com', 'full_name' => 'OC Thanarpara', 'phone_number' => '9999999999', 'address' => 'Thanarpara', 'role' => 'superior', 'station' => 'Thanarpara'],
            ['email' => 'ocpalashipara@gmail.com', 'full_name' => 'OC Palashipara', 'phone_number' => '9999999999', 'address' => 'Palashipara', 'role' => 'superior', 'station' => 'Palashipara'],
            ['email' => 'psmurutianadia@gmail.com', 'full_name' => 'OC Murutia PS KPD', 'phone_number' => '7872048330', 'address' => 'Murutia PS KPD', 'role' => 'user', 'station' => null],
            ['email' => 'juranpurrop@gmail.com', 'full_name' => 'Juranpur ROP', 'phone_number' => '9147888279', 'address' => 'Juranpur', 'role' => 'admin', 'station' => 'Juranpur ROP'],
            ['email' => 'bhimpurps@gmail.com', 'full_name' => 'Bhimpur PS', 'phone_number' => '9999999999', 'address' => 'Bhimpur', 'role' => 'admin', 'station' => 'Bhimpur'],
            ['email' => 'hogalberiaps@gmail.com', 'full_name' => 'Hogalberia PS', 'phone_number' => '9999999999', 'address' => 'Hogalberia', 'role' => 'admin', 'station' => 'Hogalberia'],
            ['email' => 'icdebogram@gmail.com', 'full_name' => 'IC Debogram', 'phone_number' => '9147888310', 'address' => 'Debogram', 'role' => 'superior', 'station' => 'Debogram ROP'],
            ['email' => 'ickrishnaganj@gmail.com', 'full_name' => 'IC Krishnaganj', 'phone_number' => '999999999', 'address' => 'Krishnaganj', 'role' => 'superior', 'station' => 'Krishnaganj'],
            ['email' => 'ocmurutia@gmail.com', 'full_name' => 'OC Murutia', 'phone_number' => '9999999999', 'address' => 'Murutia', 'role' => 'superior', 'station' => 'Murutia'],
            ['email' => 'nakashiparaps@gmail.com', 'full_name' => 'Nakashipara PS', 'phone_number' => '9999999999', 'address' => 'Nakashipara', 'role' => 'admin', 'station' => 'Nakashipara'],
            ['email' => 'icmirarop@gmail.com', 'full_name' => 'Mira ROP', 'phone_number' => '9147888308', 'address' => 'Mira, Kaliganj', 'role' => 'superior', 'station' => 'Mira ROP'],
            ['email' => 'icnabadwip@gmail.com', 'full_name' => 'IC Nabadwip', 'phone_number' => '999999999', 'address' => 'Nabadwip', 'role' => 'superior', 'station' => 'Nabadwip'],
            ['email' => 'icchapra@gmail.com', 'full_name' => 'IC Chapra', 'phone_number' => '9147888300', 'address' => 'Chapra', 'role' => 'superior', 'station' => 'Chapra'],
            ['email' => 'ocbhimpur@gmail.com', 'full_name' => 'OC Bhimpur', 'phone_number' => '999999999', 'address' => 'Bhimpur', 'role' => 'superior', 'station' => 'Bhimpur'],
            ['email' => 'pstehattanadia@gmail.com', 'full_name' => 'Avijit Biswas', 'phone_number' => '9147888296', 'address' => 'Tehatta Police Station', 'role' => 'user', 'station' => null],
            ['email' => 'superadmin@gmail.com', 'full_name' => 'Super Admin', 'phone_number' => '0000000000', 'address' => 'N/A', 'role' => 'super', 'station' => null],
            ['email' => 'ickotwali@gmail.com', 'full_name' => 'IC Kotwali', 'phone_number' => '8765432109', 'address' => 'Kotwali, Krishnanagar', 'role' => 'superior', 'station' => 'Kotwali PS'],
            ['email' => 'nabadwipps@gmail.com', 'full_name' => 'Nabadwip PS', 'phone_number' => '9988998899', 'address' => 'Nabadwip', 'role' => 'admin', 'station' => 'Nabadwip'],
            ['email' => 'krishnaganjps@gmail.com', 'full_name' => 'Krishnaganj PS', 'phone_number' => '9999999999', 'address' => 'Krishnaganj PS', 'role' => 'admin', 'station' => 'Krishnaganj'],
            ['email' => 'tehattaps@gmail.com', 'full_name' => 'Tehatta PS', 'phone_number' => '9147888296', 'address' => 'Tehatta', 'role' => 'admin', 'station' => 'Tehatta PS'],
        ];

        foreach ($users as $userData) {
            $stationId = null;
            if ($userData['station']) {
                $stationId = PoliceStation::where('name', $userData['station'])->first()?->id;
            }

            $user = User::updateOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['full_name'], // name field is used in model too, but full_name is also there.
                    'full_name' => $userData['full_name'],
                    'phone_number' => $userData['phone_number'],
                    'address' => $userData['address'],
                    'password' => $password,
                    'police_station_id' => $stationId,
                ]
            );

            $user->assignRole($userData['role']);
        }
    }
}

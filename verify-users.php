<?php

use App\Models\User;

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$emails = ['testic@example.com', 'testps@example.com'];
$users = User::whereIn('email', $emails)->get();

foreach ($emails as $email) {
    $user = $users->where('email', $email)->first();
    if ($user) {
        $tokenStatus = $user->fcm_token ? "✅ FOUND (starts with: " . substr($user->fcm_token, 0, 15) . "...)" : "❌ NULL";
        echo "Email: $email | Token: $tokenStatus\n";
    } else {
        echo "Email: $email | ❌ NOT FOUND in database\n";
    }
}

<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Complaint;

foreach(['testic@example.com', 'testps@example.com'] as $email) {
    $u = User::where('email', $email)->first();
    if ($u) {
        $count = $u->unreadNotifications->count();
        echo "Email: $email | Unread count: $count\n";
        foreach($u->unreadNotifications as $n) {
            echo " - " . ($n->data['title'] ?? 'No Title') . " (ID: " . $n->id . ")\n";
        }
    }
}

$recent = Complaint::where('police_station_id', 16)->where('created_at', '>', now()->subHour())->count();
echo "Recent complaints in PS 16: $recent\n";

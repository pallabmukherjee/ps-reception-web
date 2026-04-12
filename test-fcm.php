<?php

use App\Models\User;
use App\Notifications\HighPriorityComplaint;
use App\Models\Complaint;
use Illuminate\Support\Facades\Notification;

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// --- TEST CONFIGURATION ---
$email = $argv[1] ?? 'testic@example.com'; 
// --------------------------

$user = User::where('email', $email)->first();

if (!$user) {
    echo "❌ Error: User $email not found in database.\n";
    exit(1);
}

if (!$user->fcm_token) {
    echo "❌ Error: User $email has NO FCM token registered. Please log in on the mobile app first.\n";
    exit(1);
}

echo "✅ Found User: " . $user->name . "\n";
echo "✅ FCM Token: " . substr($user->fcm_token, 0, 20) . "...\n";

try {
    echo "⏳ Attempting to send test notification...\n";
    
    // Create a dummy complaint for the notification
    $complaint = Complaint::first() ?? new Complaint([
        'complainant_name' => 'Test System',
        'phone' => '1234567890',
        'sub_category_id' => 1
    ]);

    $notification = new HighPriorityComplaint($complaint);
    $user->notify($notification);
    
    echo "🚀 Success! Laravel reports the notification was handed over to the FCM Channel.\n";
    echo "📢 Please check your device for the '🚨 EMERGENCY HIGH ALERT 🚨' alert.\n";

} catch (\Exception $e) {
    echo "❌ FCM ERROR: " . $e->getMessage() . "\n";
    echo "📂 Trace: " . $e->getFile() . " on line " . $e->getLine() . "\n";
}

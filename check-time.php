<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo 'Laravel Config Timezone: ' . config('app.timezone') . "\n";
echo 'Laravel Now: ' . now() . "\n";

try {
    $dbNow = DB::select('SELECT NOW() as now')[0]->now;
    $dbTz = DB::select('SELECT @@session.time_zone as tz')[0]->tz;
    echo "DB Now: $dbNow\n";
    echo "DB Session TZ: $dbTz\n";
} catch (\Exception $e) {
    echo "DB Error: " . $e->getMessage() . "\n";
}

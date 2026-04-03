<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Recreate Firebase Auth JSON if missing but Base64 exists in ENV
        $base64Credentials = env('FIREBASE_CREDENTIALS_JSON_BASE64');
        $filePath = storage_path('app/firebase-auth.json');
        
        if ($base64Credentials && !file_exists($filePath)) {
            file_put_contents($filePath, base64_decode($base64Credentials));
        }
    }
}

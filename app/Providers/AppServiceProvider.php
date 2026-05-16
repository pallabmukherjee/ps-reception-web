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
        // Resolve Firebase credentials:
        // 1. Prefer base64 env var → inline JSON string (avoids file path issues)
        // 2. Fall back to credentials file on disk
        $base64Credentials = env('FIREBASE_CREDENTIALS_JSON_BASE64');
        $filePath = storage_path('app/firebase-auth.json');

        if ($base64Credentials) {
            $decoded = base64_decode($base64Credentials, true);
            if ($decoded !== false && str_starts_with(trim($decoded), '{')) {
                config()->set('firebase.projects.app.credentials', $decoded);
                return;
            }
        }

        if (file_exists($filePath)) {
            $content = file_get_contents($filePath);
            if ($content !== false && str_starts_with(trim($content), '{')) {
                config()->set('firebase.projects.app.credentials', $content);
            } else {
                config()->set('firebase.projects.app.credentials', $filePath);
            }
        }
    }
}

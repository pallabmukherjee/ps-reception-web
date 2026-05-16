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
            \Log::info("FCM CRED: base64 exists, length=" . strlen($base64Credentials));
            if ($decoded !== false) {
                \Log::info("FCM CRED: decoded OK, starts_with={=" . (str_starts_with(trim($decoded), '{') ? 'yes' : 'no') . ", first100=" . substr(trim($decoded), 0, 100));
                if (str_starts_with(trim($decoded), '{')) {
                    config()->set('firebase.projects.app.credentials', $decoded);
                    \Log::info("FCM CRED: Using inline JSON from base64");
                    return;
                }
            } else {
                \Log::error("FCM CRED: base64_decode returned false (invalid base64)");
            }
        } else {
            \Log::info("FCM CRED: No base64 env var found");
        }

        if (file_exists($filePath)) {
            $content = file_get_contents($filePath);
            \Log::info("FCM CRED: file exists, content_length=" . strlen($content ?? '') . ", starts_with={=" . (str_starts_with(trim($content ?? ''), '{') ? 'yes' : 'no'));
            if ($content !== false && str_starts_with(trim($content), '{')) {
                config()->set('firebase.projects.app.credentials', $content);
                \Log::info("FCM CRED: Using inline JSON from file");
            } else {
                config()->set('firebase.projects.app.credentials', $filePath);
                \Log::info("FCM CRED: Using file path (not inline JSON)");
            }
        } else {
            \Log::warning("FCM CRED: No credentials file found at " . $filePath);
        }
    }
}

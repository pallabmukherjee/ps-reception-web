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
        // Share settings with all views
        if (!app()->runningInConsole()) {
            try {
                if (\Schema::hasTable('settings')) {
                    $settings = \App\Models\Setting::all()->pluck('value', 'key')->toArray();
                    view()->share('site_settings', $settings);
                }
            } catch (\Exception $e) {
                // Ignore errors if table doesn't exist yet
            }
        }

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

                // Validate JSON — strip control chars (keep tab, newline, return)
                $clean = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/', '', $decoded);
                $test = json_decode($clean, true, 512, JSON_INVALID_UTF8_SUBSTITUTE);
                $jsonError = json_last_error_msg();

                if ($test !== null) {
                    // Re-encode to clean JSON, write to file, use file path
                    $cleanJson = json_encode($test, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
                    file_put_contents($filePath, $cleanJson);
                    config()->set('firebase.projects.app.credentials', $filePath);
                    \Log::info("FCM CRED: Control chars stripped, cleaned JSON written to file, using file path");
                    return;
                }
                \Log::error("FCM CRED: JSON still invalid after stripping control chars: $jsonError");
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
                $clean = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/', '', $content);
                $test = json_decode($clean, true, 512, JSON_INVALID_UTF8_SUBSTITUTE);
                $jsonError = json_last_error_msg();
                if ($test !== null) {
                    $cleanJson = json_encode($test, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
                    file_put_contents($filePath, $cleanJson);
                    config()->set('firebase.projects.app.credentials', $filePath);
                    \Log::info("FCM CRED: Using file path from file (cleaned)");
                } else {
                    \Log::error("FCM CRED: File content invalid JSON even after cleaning: $jsonError");
                }
            } else {
                config()->set('firebase.projects.app.credentials', $filePath);
                \Log::info("FCM CRED: Using file path (no inline JSON)");
            }
        } else {
            \Log::warning("FCM CRED: No credentials file found at " . $filePath);
        }
    }
}

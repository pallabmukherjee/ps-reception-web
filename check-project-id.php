<?php

$filePath = __DIR__ . '/storage/app/firebase-auth.json';

if (!file_exists($filePath)) {
    echo "❌ Error: $filePath not found.\n";
    exit(1);
}

$content = file_get_contents($filePath);
$json = json_decode($content, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo "❌ Error: Invalid JSON in $filePath. Error: " . json_last_error_msg() . "\n";
    exit(1);
}

echo "✅ Project ID: " . ($json['project_id'] ?? 'MISSING') . "\n";
echo "✅ Client Email: " . ($json['client_email'] ?? 'MISSING') . "\n";

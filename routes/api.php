<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ComplaintApiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('login', function() {
    return response()->json(['message' => 'Login API is working. Please use POST to login.']);
});

Route::post('login', [AuthController::class, 'login']);

// Complaint Metadata (Publicly accessible)
Route::get('metadata', [ComplaintApiController::class, 'getMetadata']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('user', function (Request $request) {
        return $request->user();
    });

    Route::post('logout', [AuthController::class, 'logout']);
    Route::post('update-fcm-token', [AuthController::class, 'updateFcmToken']);
    Route::post('test-notification', [ComplaintApiController::class, 'sendTestNotification']);

    // Complaint APIs
    Route::get('complaints/{complaint}', [ComplaintApiController::class, 'show']);
    Route::post('complaints', [ComplaintApiController::class, 'store']);
    Route::patch('complaints/{complaint}', [ComplaintApiController::class, 'update']);
    Route::delete('complaints/{complaint}', [ComplaintApiController::class, 'destroy']);
    Route::get('my-complaints', [ComplaintApiController::class, 'myComplaints']);

    // Statistics API
    Route::get('statistics', [ComplaintApiController::class, 'getStatistics']);

    // Profile APIs
    Route::get('profile', [\App\Http\Controllers\Api\ProfileApiController::class, 'getProfile']);
    Route::post('profile', [\App\Http\Controllers\Api\ProfileApiController::class, 'updateProfile']);
    Route::post('change-password', [\App\Http\Controllers\Api\ProfileApiController::class, 'changePassword']);

    // Note API
    Route::post('complaints/{complaint}/note', [ComplaintApiController::class, 'addNote']);

    // Notifications API
    Route::get('notifications', [ComplaintApiController::class, 'notifications']);
    Route::post('notifications/mark-read', [ComplaintApiController::class, 'markNotificationsRead']);
});

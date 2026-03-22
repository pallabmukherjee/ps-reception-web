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

    // Complaint APIs
    Route::post('complaints', [ComplaintApiController::class, 'store']);
    Route::patch('complaints/{complaint}', [ComplaintApiController::class, 'update']);
    Route::delete('complaints/{complaint}', [ComplaintApiController::class, 'destroy']);
    Route::get('my-complaints', [ComplaintApiController::class, 'myComplaints']);
});

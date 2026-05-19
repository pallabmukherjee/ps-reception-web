<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PoliceStationController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\SubCategoryController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ComplaintController;
use App\Http\Controllers\StatisticsController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('login');
});

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    
    // Resource Routes
    Route::resource('police-stations', PoliceStationController::class)->except(['create', 'show', 'edit']);
    Route::resource('categories', CategoryController::class)->except(['create', 'show', 'edit']);
    Route::patch('categories/{category}/toggle', [CategoryController::class, 'toggleStatus'])->name('categories.toggle');
    
    Route::patch('sub-categories/{sub_category}/toggle', [SubCategoryController::class, 'toggleStatus'])->name('sub-categories.toggle');
    Route::resource('sub-categories', SubCategoryController::class)->except(['create', 'show', 'edit']);
    
    Route::resource('users', UserController::class)->except(['create', 'show', 'edit']);

    // Complaints
    Route::get('/complaints', [ComplaintController::class, 'index'])->name('complaints.index');
    Route::get('/complaints/download', [ComplaintController::class, 'downloadCsv'])->name('complaints.download');
    Route::post('/complaints/{complaint}/note', [ComplaintController::class, 'addNote'])->name('complaints.note');
    Route::delete('/complaints/{complaint}', [ComplaintController::class, 'destroy'])->name('complaints.destroy');

    // Statistics
    Route::get('/statistics', [StatisticsController::class, 'index'])->name('statistics.index');

    // Settings
    Route::get('/settings/site', [\App\Http\Controllers\SettingController::class, 'index'])->name('settings.site');
    Route::patch('/settings/site', [\App\Http\Controllers\SettingController::class, 'update'])->name('settings.update');
    
    Route::get('/settings/action-taken', [\App\Http\Controllers\ActionTakenController::class, 'index'])->name('settings.action-taken.index');
    Route::post('/settings/action-taken', [\App\Http\Controllers\ActionTakenController::class, 'store'])->name('settings.action-taken.store');
    Route::patch('/settings/action-taken/{actionTaken}', [\App\Http\Controllers\ActionTakenController::class, 'update'])->name('settings.action-taken.update');
    Route::delete('/settings/action-taken/{actionTaken}', [\App\Http\Controllers\ActionTakenController::class, 'destroy'])->name('settings.action-taken.destroy');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';

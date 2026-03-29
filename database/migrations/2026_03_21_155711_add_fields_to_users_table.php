<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone_number')->nullable();
            $table->string('address')->nullable();
            $table->foreignId('police_station_id')->nullable()->constrained()->onDelete('set null');
            $table->string('fcm_token')->nullable();
            $table->string('full_name')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['police_station_id']);
            $table->dropColumn(['phone_number', 'address', 'police_station_id', 'fcm_token', 'full_name']);
        });
    }
};

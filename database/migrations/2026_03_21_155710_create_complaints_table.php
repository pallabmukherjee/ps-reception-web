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
        Schema::create('complaints', function (Blueprint $table) {
            $table->id();
            $table->string('complainant_name');
            $table->string('phone');
            $table->text('address');
            $table->foreignId('sub_category_id')->constrained()->onDelete('cascade');
            $table->text('description')->nullable();
            $table->foreignId('receptionist_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('police_station_id')->constrained()->onDelete('cascade');
            $table->boolean('is_editable')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('complaints');
    }
};

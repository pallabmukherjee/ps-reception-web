<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Complaint extends Model
{
    protected $fillable = [
        'firebase_id',
        'complainant_name',
        'phone',
        'address',
        'sub_category_id',
        'description',
        'receptionist_id',
        'police_station_id',
        'is_editable',
        'note',
        'note_updated_at',
        'created_at',
    ];

    public function subCategory()
    {
        return $this->belongsTo(SubCategory::class);
    }

    public function receptionist()
    {
        return $this->belongsTo(User::class, 'receptionist_id');
    }

    public function policeStation()
    {
        return $this->belongsTo(PoliceStation::class);
    }
}

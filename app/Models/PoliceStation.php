<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PoliceStation extends Model
{
    protected $fillable = ['name', 'notification_id'];

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function complaints()
    {
        return $this->hasMany(Complaint::class);
    }
}

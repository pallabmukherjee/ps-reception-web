<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubCategory extends Model
{
    protected $fillable = ['category_id', 'name', 'is_disabled'];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function complaints()
    {
        return $this->hasMany(Complaint::class);
    }
}

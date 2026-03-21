<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    protected $fillable = ['name', 'notification_enabled', 'priority'];

    public function subCategories()
    {
        return $this->hasMany(SubCategory::class);
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SettingController extends Controller
{
    public function index()
    {
        $settings = Setting::all()->pluck('value', 'key')->toArray();
        return view('settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        $rules = [
            'site_name' => 'nullable|string|max:255',
            'site_description' => 'nullable|string',
            'footer_text' => 'nullable|string',
            'contact_email' => 'nullable|email',
            'contact_phone' => 'nullable|string',
            'address' => 'nullable|string',
            'site_logo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'site_favicon' => 'nullable|image|mimes:png,ico,x-icon|max:1024',
        ];

        $data = $request->validate($rules);

        foreach ($rules as $key => $rule) {
            if ($request->hasFile($key)) {
                // Delete old file if exists
                $oldValue = Setting::get($key);
                if ($oldValue) {
                    Storage::disk('public')->delete($oldValue);
                }
                
                $path = $request->file($key)->store('settings', 'public');
                Setting::set($key, $path);
            } elseif ($request->has($key)) {
                Setting::set($key, $request->input($key));
            }
        }

        return redirect()->back()->with('success', 'Settings updated successfully.');
    }
}

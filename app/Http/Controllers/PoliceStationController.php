<?php

namespace App\Http\Controllers;

use App\Models\PoliceStation;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PoliceStationController extends Controller
{
    public function index()
    {
        $policeStations = PoliceStation::latest()->get();
        return view('police-stations.index', compact('policeStations'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        PoliceStation::create([
            'name' => $request->name,
            'notification_id' => Str::random(10),
        ]);

        return redirect()->back()->with('success', 'Police Station added successfully.');
    }

    public function update(Request $request, PoliceStation $policeStation)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $policeStation->update([
            'name' => $request->name,
        ]);

        return redirect()->back()->with('success', 'Police Station updated successfully.');
    }

    public function destroy(PoliceStation $policeStation)
    {
        $policeStation->delete();
        return redirect()->back()->with('success', 'Police Station deleted successfully.');
    }
}

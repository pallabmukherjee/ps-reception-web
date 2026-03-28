<?php

namespace App\Http\Controllers;

use App\Models\Complaint;
use App\Models\PoliceStation;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        
        if ($user->hasRole('superior')) {
            $totalEntries = Complaint::where('police_station_id', $user->police_station_id)->count();
            $policeStations = PoliceStation::where('id', $user->police_station_id)->get();
        } else {
            $totalEntries = Complaint::count();
            $policeStations = PoliceStation::all();
        }
        
        $stationCounts = Complaint::select('police_station_id', \DB::raw('count(*) as total'))
            ->groupBy('police_station_id')
            ->pluck('total', 'police_station_id');

        return view('dashboard', compact('totalEntries', 'policeStations', 'stationCounts'));
    }
}

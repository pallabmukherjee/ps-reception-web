<?php

namespace App\Http\Controllers;

use App\Models\Complaint;
use App\Models\PoliceStation;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        $totalEntries = Complaint::count();
        $policeStations = PoliceStation::all();
        
        $stationCounts = Complaint::select('police_station_id', \DB::raw('count(*) as total'))
            ->groupBy('police_station_id')
            ->pluck('total', 'police_station_id');

        return view('dashboard', compact('totalEntries', 'policeStations', 'stationCounts'));
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\Complaint;
use App\Models\PoliceStation;
use App\Models\SubCategory;
use Illuminate\Http\Request;

class StatisticsController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        $policeStations = PoliceStation::all();
        $selectedStationId = $request->input('police_station_id');

        if ($user->hasRole('superior')) {
            $selectedStationId = $user->police_station_id;
        }
        
        $complaints = collect();
        $complaintStats = null;
        $selectedStation = null;

        if ($selectedStationId) {
            $selectedStation = PoliceStation::find($selectedStationId);
            $complaints = Complaint::where('police_station_id', $selectedStationId)->get();
            
            // Replicate React reduce logic: acc[complaint.complainType] = (acc[complaint.complainType] || 0) + 1;
            $complaintStats = [];
            foreach ($complaints as $complaint) {
                $type = $complaint->subCategory->name ?? 'Unknown';
                $complaintStats[$type] = ($complaintStats[$type] ?? 0) + 1;
            }
            
            // Sort by count descending for better visuals
            arsort($complaintStats);
        }

        return view('statistics.index', compact('policeStations', 'selectedStation', 'complaintStats', 'complaints'));
    }
}

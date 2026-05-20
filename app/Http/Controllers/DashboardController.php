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
        
        $query = Complaint::query();
        $stationsQuery = PoliceStation::query();

        if ($user->hasRole('superior')) {
            $query->where('police_station_id', $user->police_station_id);
            $stationsQuery->where('id', $user->police_station_id);
        }

        $totalEntries = (clone $query)->count();
        $totalPending = (clone $query)->whereNull('action_taken')->count();
        $totalOverdueSensitive = (clone $query)->whereNull('action_taken')
            ->where('created_at', '<', now()->subHours(24))
            ->whereHas('subCategory.category', function($q) {
                $q->where('priority', 'High Priority');
            })->count();
            
        $policeStations = $stationsQuery->get();
        
        $stats = (clone $query)->select('police_station_id',
            \DB::raw('count(*) as total'),
            \DB::raw('count(CASE WHEN action_taken IS NOT NULL THEN 1 END) as resolved'),
            \DB::raw('count(CASE WHEN action_taken IS NULL THEN 1 END) as pending'),
            \DB::raw('count(CASE WHEN action_taken IS NULL AND created_at < "' . now()->subHours(24) . '" AND EXISTS (
                SELECT 1 FROM sub_categories 
                JOIN categories ON sub_categories.category_id = categories.id 
                WHERE sub_categories.id = complaints.sub_category_id 
                AND categories.priority = "High Priority"
            ) THEN 1 END) as overdue_sensitive')
        )
        ->groupBy('police_station_id')
        ->get()
        ->keyBy('police_station_id');

        return view('dashboard', compact('totalEntries', 'totalPending', 'totalOverdueSensitive', 'policeStations', 'stats'));
    }
}

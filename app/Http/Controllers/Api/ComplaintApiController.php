<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\PoliceStation;
use App\Models\SubCategory;
use Illuminate\Http\Request;

class ComplaintApiController extends Controller
{
    public function getMetadata()
    {
        return response()->json([
            'police_stations' => PoliceStation::select('id', 'name')->get(),
            'sub_categories' => SubCategory::where('is_disabled', false)
                ->whereHas('category', function($query) {
                    $query->where('is_disabled', false);
                })
                ->select('id', 'name', 'category_id')
                ->get(),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'complainant_name' => 'required|string',
            'phone' => 'required|string',
            'address' => 'required|string',
            'sub_category_id' => 'required|exists:sub_categories,id',
            'police_station_id' => 'required|exists:police_stations,id',
            'description' => 'nullable|string',
        ]);

        $complaint = Complaint::create([
            'complainant_name' => $request->complainant_name,
            'phone' => $request->phone,
            'address' => $request->address,
            'sub_category_id' => $request->sub_category_id,
            'police_station_id' => $request->police_station_id,
            'description' => $request->description,
            'receptionist_id' => auth()->id(),
            'is_editable' => false,
        ]);

        return response()->json([
            'message' => 'Complaint stored successfully',
            'id' => $complaint->id
        ], 201);
    }

    public function myComplaints()
    {
        $user = auth()->user();
        $query = Complaint::with(['subCategory.category', 'policeStation']);

        if ($user->hasRole(['super', 'admin'])) {
            // Admins and super users see all complaints
        } elseif ($user->hasRole('superior')) {
            // Superiors see all complaints in their police station
            $query->where('police_station_id', $user->police_station_id);
        } else {
            // Regular users (receptionists) see only their own complaints
            $query->where('receptionist_id', $user->id);
        }

        $complaints = $query->latest()->get();

        return response()->json($complaints);
    }

    public function update(Request $request, Complaint $complaint)
    {
        $user = auth()->user();
        
        // Check if user is allowed to edit
        if (!$complaint->is_editable && !$user->hasRole(['super', 'admin'])) {
            return response()->json(['message' => 'This complaint is no longer editable.'], 403);
        }

        $request->validate([
            'complainant_name' => 'required|string',
            'phone' => 'required|string',
            'address' => 'required|string',
            'sub_category_id' => 'required|exists:sub_categories,id',
            'police_station_id' => 'required|exists:police_stations,id',
            'description' => 'nullable|string',
        ]);

        $complaint->update([
            'complainant_name' => $request->complainant_name,
            'phone' => $request->phone,
            'address' => $request->address,
            'sub_category_id' => $request->sub_category_id,
            'police_station_id' => $request->police_station_id,
            'description' => $request->description,
        ]);

        return response()->json(['message' => 'Complaint updated successfully']);
    }

    public function destroy(Complaint $complaint)
    {
        $user = auth()->user();

        // Superiors and Admins can delete
        if (!$user->hasRole(['super', 'admin', 'superior'])) {
            return response()->json(['message' => 'Unauthorized to delete complaints.'], 403);
        }

        // Superior can only delete complaints from their station
        if ($user->hasRole('superior') && $complaint->police_station_id !== $user->police_station_id) {
            return response()->json(['message' => 'Unauthorized to delete complaints from other stations.'], 403);
        }

        $complaint->delete();

        return response()->json(['message' => 'Complaint deleted successfully']);
    }
}

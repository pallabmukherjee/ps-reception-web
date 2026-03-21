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
            'sub_categories' => SubCategory::where('is_disabled', false)->select('id', 'name', 'category_id')->get(),
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
        $complaints = Complaint::with(['subCategory.category', 'policeStation'])
            ->where('receptionist_id', auth()->id())
            ->latest()
            ->get();

        return response()->json($complaints);
    }
}

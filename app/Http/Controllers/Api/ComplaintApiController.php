<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\PoliceStation;
use App\Models\SubCategory;
use App\Models\User;
use App\Notifications\HighPriorityComplaint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Notification;

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
            'is_editable' => true,
        ]);

        // Trigger Notification for High Priority categories
        try {
            $subCategory = SubCategory::with('category')->find($request->sub_category_id);
            $category = $subCategory->category;
            
            if ($category) {
                $priority = $category->priority ?? 'none';
                $isNotificationEnabled = $category->notification_enabled ?? false;
                $categoryId = $category->id;

                // Priority check: Matches High Priority string or specific Red category IDs (1, 5). Keeping 9 for testing.
                $isHighPriority = (strcasecmp(trim($priority), 'High Priority') === 0) || 
                                 in_array($categoryId, [1, 5, 9]);

                if ($isHighPriority && $isNotificationEnabled) {
                    // Find all superiors in this station
                    $superiors = User::role('superior')
                        ->where('police_station_id', $request->police_station_id)
                        ->get();

                    if ($superiors->isNotEmpty()) {
                        Notification::send($superiors, new HighPriorityComplaint($complaint));
                    }
                }
            }
        } catch (\Exception $e) {
            \Log::error("Notification triggering failed: " . $e->getMessage());
        }

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
        
        \Log::info('Complaint Update Request:', [
            'complaint_id' => $complaint->id,
            'user_id' => $user->id,
            'data' => $request->all()
        ]);

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

        try {
            $complaint->update([
                'complainant_name' => $request->complainant_name,
                'phone' => $request->phone,
                'address' => $request->address,
                'sub_category_id' => $request->sub_category_id,
                'police_station_id' => $request->police_station_id,
                'description' => $request->description,
            ]);
            
            \Log::info('Complaint Updated Successfully');
        } catch (\Exception $e) {
            \Log::error('Complaint Update Failed: ' . $e->getMessage());
            return response()->json(['message' => 'Update failed: ' . $e->getMessage()], 500);
        }

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

    public function notifications()
    {
        $user = auth()->user();
        $notifications = $user->unreadNotifications;
        return response()->json($notifications);
    }

    public function markNotificationsRead()
    {
        auth()->user()->unreadNotifications->markAsRead();
        return response()->json(['message' => 'Notifications marked as read']);
    }
}

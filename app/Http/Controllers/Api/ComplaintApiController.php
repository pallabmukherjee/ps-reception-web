<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\PoliceStation;
use App\Models\SubCategory;
use App\Models\User;
use App\Notifications\HighPriorityComplaint;
use App\Notifications\SuperiorNoteAdded;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

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

    public function show(Request $request, Complaint $complaint)
    {
        $complaint->load(['subCategory.category', 'policeStation', 'receptionist']);
        $user = auth()->user();
        $dutyStartTime = $request->input('duty_start_time');

        if ($user->hasRole('super')) {
            $complaint->is_editable = true;
        } elseif ($user->hasRole('superior')) {
            $complaint->is_editable = ((int)$complaint->police_station_id === (int)$user->police_station_id);
        } elseif ($user->hasRole('admin')) {
            $isOwn = ((int)$complaint->receptionist_id === (int)$user->id);
            $isWithinDuty = false; // Default to false for safety
            if ($dutyStartTime) {
                try {
                    $dutyDate = \Carbon\Carbon::parse($dutyStartTime);
                    $isWithinDuty = $complaint->created_at->greaterThanOrEqualTo($dutyDate);
                } catch (\Exception $e) {
                    \Log::error("Duty start time parsing failed in show: " . $e->getMessage());
                }
            }
            $complaint->is_editable = $isOwn && $isWithinDuty;
        } else {
            $complaint->is_editable = ((int)$complaint->receptionist_id === (int)$user->id);
        }

        return response()->json($complaint);
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
            'receptionist_name' => 'nullable|string',
            'receptionist_mobile' => 'nullable|string',
        ]);

        $complaint = Complaint::create([
            'complainant_name' => $request->complainant_name,
            'phone' => $request->phone,
            'address' => $request->address,
            'sub_category_id' => $request->sub_category_id,
            'police_station_id' => $request->police_station_id,
            'description' => $request->description,
            'receptionist_id' => auth()->id(),
            'receptionist_name' => $request->receptionist_name,
            'receptionist_mobile' => $request->receptionist_mobile,
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

                $isHighPriority = (strcasecmp(trim($priority), 'High Priority') === 0) || 
                                 in_array($categoryId, [1, 5, 9]);

                if ($isHighPriority && $isNotificationEnabled) {
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

    public function myComplaints(Request $request)
    {
        $user = auth()->user();
        $query = Complaint::with(['subCategory.category', 'policeStation', 'receptionist']);

        if ($user->hasRole('super')) {
            // Full access for super-admin
        } elseif ($user->hasRole('superior')) {
            // Superior: See all station records (no time limit as per latest requirement)
            if ($user->police_station_id) {
                $query->where('police_station_id', $user->police_station_id);
            }
        } elseif ($user->hasRole('admin')) {
            // Admin (Receptionist): Restricted to station and last 24 hours
            if ($user->police_station_id) {
                $query->where('police_station_id', $user->police_station_id);
            }
            $query->where('created_at', '>=', now()->subHours(24));
        } else {
            // Regular User: Only show their own from last 24 hours
            $query->where('receptionist_id', $user->id);
            $query->where('created_at', '>=', now()->subHours(24));
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('complainant_name', 'like', "%$search%")
                  ->orWhere('phone', 'like', "%$search%")
                  ->orWhere('address', 'like', "%$search%")
                  ->orWhereHas('subCategory', function($q2) use ($search) {
                      $q2->where('name', 'like', "%$search%");
                  });
            });
        }

        if ($request->filled('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }
        if ($request->filled('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        $perPage = $request->input('per_page', 20);
        $complaints = $query->latest()->paginate($perPage);

        // Add is_editable flag based on complex rules
        $dutyStartTime = $request->input('duty_start_time');
        
        $complaints->getCollection()->transform(function($complaint) use ($user, $dutyStartTime) {
            if ($user->hasRole('super')) {
                $complaint->is_editable = true;
            } elseif ($user->hasRole('superior')) {
                // Superior can manage any record in their station
                $complaint->is_editable = ((int)$complaint->police_station_id === (int)$user->police_station_id);
            } elseif ($user->hasRole('admin')) {
                // Admin (Receptionist) can only edit if they are the creator AND it was during current duty session
                $isOwn = ((int)$complaint->receptionist_id === (int)$user->id);
                $isWithinDuty = false; // Default to false for safety
                if ($dutyStartTime) {
                    try {
                        $dutyDate = \Carbon\Carbon::parse($dutyStartTime);
                        $isWithinDuty = $complaint->created_at->greaterThanOrEqualTo($dutyDate);
                    } catch (\Exception $e) {
                        \Log::error("Duty start time parsing failed: " . $e->getMessage());
                    }
                }
                $complaint->is_editable = $isOwn && $isWithinDuty;
            } else {
                $complaint->is_editable = ((int)$complaint->receptionist_id === (int)$user->id);
            }
            return $complaint;
        });

        return response()->json($complaints);
    }

    public function addNote(Request $request, Complaint $complaint)
    {
        $user = auth()->user();
        if (!$user->hasRole(['super', 'admin', 'superior'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'note' => 'required|string',
        ]);

        $complaint->update([
            'note' => $request->note,
            'note_updated_at' => now(),
        ]);

        // Notify receptionist and admins
        try {
            $receptionist = $complaint->receptionist;
            $admins = User::role(['admin', 'super'])->get();
            
            $notification = new SuperiorNoteAdded($complaint);
            
            if ($receptionist) {
                $receptionist->notify($notification);
            }
            
            Notification::send($admins, $notification);
        } catch (\Exception $e) {
            \Log::error("Note notification failed: " . $e->getMessage());
        }

        return response()->json(['message' => 'Note added successfully', 'note' => $complaint->note]);
    }

    public function update(Request $request, Complaint $complaint)
    {
        $user = auth()->user();
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

        $complaint->update($request->only(['complainant_name', 'phone', 'address', 'sub_category_id', 'police_station_id', 'description']));

        return response()->json(['message' => 'Complaint updated successfully']);
    }

    public function destroy(Complaint $complaint)
    {
        $user = auth()->user();
        if (!$user->hasRole(['super', 'admin', 'superior'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($user->hasRole('superior') && $complaint->police_station_id !== $user->police_station_id) {
            return response()->json(['message' => 'Unauthorized station'], 403);
        }

        $complaint->delete();
        return response()->json(['message' => 'Complaint deleted successfully']);
    }

    public function getStatistics(Request $request)
    {
        $user = auth()->user();
        $stationId = $request->input('police_station_id', $user->hasRole('superior') ? $user->police_station_id : null);

        $query = Complaint::query();
        if ($stationId) {
            $query->where('police_station_id', $stationId);
        }

        $complaints = $query->get();
        $stats = $complaints->groupBy(fn($c) => $c->subCategory->name ?? 'Unknown')->map->count();

        return response()->json([
            'total' => $complaints->count(),
            'stats' => $stats->sortDesc(),
            'station_name' => $stationId ? PoliceStation::find($stationId)->name : 'All Stations'
        ]);
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\Complaint;
use App\Models\PoliceStation;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Notification;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ComplaintController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        $policeStations = PoliceStation::all();
        $subCategories = \App\Models\SubCategory::all();
        $actionTakenList = \App\Models\ActionTaken::all();
        
        $selectedStation = $request->input('police_station_id');
        $selectedSubCategory = $request->input('sub_category_id');
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        $searchTerm = $request->input('search');

        $query = Complaint::with(['subCategory.category', 'receptionist', 'policeStation']);

        if ($user->hasRole('superior')) {
            $query->where('police_station_id', $user->police_station_id);
            $selectedStation = $user->police_station_id;
        } elseif ($selectedStation) {
            $query->where('police_station_id', $selectedStation);
        }

        if ($selectedSubCategory) {
            $query->where('sub_category_id', $selectedSubCategory);
        }

        if ($startDate) {
            $query->whereDate('created_at', '>=', $startDate);
        }
        if ($endDate) {
            $query->whereDate('created_at', '<=', $endDate);
        }

        if ($searchTerm) {
            $query->where(function($q) use ($searchTerm) {
                $q->where('complainant_name', 'like', "%{$searchTerm}%")
                  ->orWhere('phone', 'like', "%{$searchTerm}%")
                  ->orWhere('address', 'like', "%{$searchTerm}%")
                  ->orWhere('description', 'like', "%{$searchTerm}%")
                  ->orWhereHas('subCategory', function($subQ) use ($searchTerm) {
                      $subQ->where('name', 'like', "%{$searchTerm}%");
                  });
            });
        }

        $complaints = $query->latest()->paginate(10)->withQueryString();

        return view('complaints.index', compact(
            'complaints', 'policeStations', 'subCategories', 'actionTakenList', 
            'selectedStation', 'selectedSubCategory', 'startDate', 'endDate', 'searchTerm'
        ));
    }

    public function downloadCsv(Request $request)
    {
        $user = auth()->user();
        $selectedStation = $request->input('police_station_id');
        $selectedSubCategory = $request->input('sub_category_id');
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        $searchTerm = $request->input('search');

        $query = Complaint::with(['subCategory.category', 'receptionist', 'policeStation']);

        if ($user->hasRole('superior')) {
            $query->where('police_station_id', $user->police_station_id);
        } elseif ($selectedStation) {
            $query->where('police_station_id', $selectedStation);
        }

        if ($selectedSubCategory) {
            $query->where('sub_category_id', $selectedSubCategory);
        }

        if ($startDate) {
            $query->whereDate('created_at', '>=', $startDate);
        }
        if ($endDate) {
            $query->whereDate('created_at', '<=', $endDate);
        }

        if ($searchTerm) {
            $query->where(function($q) use ($searchTerm) {
                $q->where('complainant_name', 'like', "%{$searchTerm}%")
                  ->orWhere('phone', 'like', "%{$searchTerm}%")
                  ->orWhere('address', 'like', "%{$searchTerm}%")
                  ->orWhere('description', 'like', "%{$searchTerm}%")
                  ->orWhereHas('subCategory', function($subQ) use ($searchTerm) {
                      $subQ->where('name', 'like', "%{$searchTerm}%");
                  });
            });
        }

        $complaints = $query->latest()->get();
        
        $response = new StreamedResponse(function() use ($complaints) {
            $handle = fopen('php://output', 'w');
            
            // CSV Header
            fputcsv($handle, [
                'Name', 'Phone', 'Address', 'Complain Type', 'Description', 
                'Police Station', 'Receptionist Name', 'Receptionist Mobile', 'Complain Register Time',
                'Action Taken', 'Action Details'
            ]);

            foreach ($complaints as $complaint) {
                fputcsv($handle, [
                    $complaint->complainant_name,
                    $complaint->phone,
                    $complaint->address,
                    $complaint->subCategory->name ?? 'N/A',
                    $complaint->description,
                    $complaint->policeStation->name ?? 'N/A',
                    $complaint->receptionist->name ?? 'N/A',
                    $complaint->receptionist->phone_number ?? 'N/A',
                    $complaint->created_at->format('d/m/Y h:i A'),
                    $complaint->action_taken ?? '',
                    $complaint->action_details ?? '',
                ]);
            }

            fclose($handle);
        });

        $response->headers->set('Content-Type', 'text/csv');
        $response->headers->set('Content-Disposition', 'attachment; filename="complaints.csv"');

        return $response;
    }

    public function destroy(Complaint $complaint)
    {
        $complaint->delete();
        return redirect()->back()->with('success', 'Complaint deleted successfully.');
    }

    public function addNote(Request $request, Complaint $complaint)
    {
        $user = auth()->user();
        if (!$user->hasRole(['super', 'admin', 'superior'])) {
            abort(403);
        }

        $request->validate([
            'action_taken' => 'nullable|string',
            'action_details' => 'nullable|string',
        ]);

        $complaint->update([
            'action_taken' => $request->action_taken,
            'action_details' => $request->action_details,
        ]);

        // Notify receptionist and admins (deduplicated)
        try {
            $receptionist = $complaint->receptionist;
            $admins = User::role('admin')->get();
            
            $recipients = $admins->keyBy('id');
            if ($receptionist) {
                $recipients->put($receptionist->id, $receptionist);
            }
            
            if ($recipients->isNotEmpty()) {
                Notification::send($recipients, new \App\Notifications\SuperiorNoteAdded($complaint));
            }
        } catch (\Exception $e) {
            \Log::error("Action notification failed: " . $e->getMessage());
        }

        return redirect()->back()->with('success', 'Official action updated successfully.');
    }
}

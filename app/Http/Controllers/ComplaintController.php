<?php

namespace App\Http\Controllers;

use App\Models\Complaint;
use App\Models\PoliceStation;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ComplaintController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        $policeStations = PoliceStation::all();
        $selectedStation = $request->input('police_station_id');
        $searchTerm = $request->input('search');

        $query = Complaint::with(['subCategory.category', 'receptionist', 'policeStation']);

        if ($user->hasRole('superior')) {
            $query->where('police_station_id', $user->police_station_id);
            $selectedStation = $user->police_station_id; // Lock station for superior
        } elseif ($selectedStation) {
            $query->where('police_station_id', $selectedStation);
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

        return view('complaints.index', compact('complaints', 'policeStations', 'selectedStation', 'searchTerm'));
    }

    public function downloadCsv(Request $request)
    {
        $user = auth()->user();
        $selectedStation = $request->input('police_station_id');
        $searchTerm = $request->input('search');

        $query = Complaint::with(['subCategory.category', 'receptionist', 'policeStation']);

        if ($user->hasRole('superior')) {
            $query->where('police_station_id', $user->police_station_id);
        } elseif ($selectedStation) {
            $query->where('police_station_id', $selectedStation);
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
            
            // CSV Header (Matching React exactly)
            fputcsv($handle, [
                'Name', 'Phone', 'Address', 'Complain Type', 'Description', 
                'Police Station', 'Receptionist Name', 'Receptionist Mobile', 'Complain Register Time'
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
            'note' => 'required|string',
        ]);

        $complaint->update([
            'note' => $request->note,
            'note_updated_at' => now(),
        ]);

        // Notify receptionist
        try {
            $receptionist = $complaint->receptionist;
            if ($receptionist) {
                $receptionist->notify(new \App\Notifications\SuperiorNoteAdded($complaint));
            }
        } catch (\Exception $e) {
            \Log::error("Note notification failed: " . $e->getMessage());
        }

        return redirect()->back()->with('success', 'Official note added successfully.');
    }
}

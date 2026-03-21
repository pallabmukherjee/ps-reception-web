<x-app-layout>
    <div class="max-w-7xl mt-6 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans">
        <h2 class="text-2xl font-bold text-center mb-4 font-mono">CSV Download</h2>

        <form action="{{ route('complaints.index') }}" method="GET" class="mb-4 flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
            <div class="w-full md:w-1/2">
                <label class="block text-sm font-medium text-gray-700 font-mono" for="policeStationSelect">
                    Select a Police Station
                </label>
                <select
                    id="policeStationSelect"
                    name="police_station_id"
                    onchange="this.form.submit()"
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm font-mono"
                >
                    <option value="">-- Select --</option>
                    @foreach($policeStations as $station)
                        <option value="{{ $station->id }}" {{ $selectedStation == $station->id ? 'selected' : '' }}>
                            {{ $station->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="w-full md:w-1/2 md:pl-4">
                <label class="block text-sm font-medium text-gray-700 font-mono" for="searchComplaints">
                    Search Complaints
                </label>
                <input
                    type="text"
                    id="searchComplaints"
                    name="search"
                    value="{{ $searchTerm }}"
                    placeholder="Search by any field..."
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm font-mono"
                />
            </div>
        </form>

        <hr class="my-6" />

        <div class="flex justify-between items-center mb-4">
            <h3 class="text-xl font-semibold font-mono text-gray-800">Complaints</h3>
            @if($selectedStation)
                <a href="{{ route('complaints.download', ['police_station_id' => $selectedStation, 'search' => $searchTerm]) }}" 
                   class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition font-mono font-bold">
                    Download CSV
                </a>
            @endif
        </div>

        <div class="space-y-4">
            @forelse($complaints as $complaint)
                <div class="p-4 border rounded-md shadow-sm bg-gray-50 font-mono relative group">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
                        <p><strong>Name:</strong> {{ $complaint->complainant_name }}</p>
                        <p><strong>Phone:</strong> {{ $complaint->phone }}</p>
                        <p class="md:col-span-2"><strong>Address:</strong> {{ $complaint->address }}</p>
                        <p><strong>Complain Type:</strong> {{ $complaint->subCategory->name ?? 'N/A' }}</p>
                        <p><strong>Police Station:</strong> {{ $complaint->policeStation->name ?? 'N/A' }}</p>
                        <p class="md:col-span-2"><strong>Description:</strong> {{ $complaint->description }}</p>
                        <p><strong>Receptionist Name:</strong> {{ $complaint->receptionist->name ?? 'N/A' }}</p>
                        <p><strong>Receptionist Mobile:</strong> {{ $complaint->receptionist->phone_number ?? 'N/A' }}</p>
                        <p class="md:col-span-2 text-blue-600"><strong>Complain Register Time:</strong> {{ $complaint->created_at->format('d/m/Y h:i A') }}</p>
                    </div>
                    
                    <!-- Delete Button (Added for admin convenience) -->
                    <form action="{{ route('complaints.destroy', $complaint) }}" method="POST" class="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
                        @csrf @method('DELETE')
                        <button type="submit" onclick="return confirm('Delete this record?')" class="text-red-500 hover:text-red-700">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                            </svg>
                        </button>
                    </form>
                </div>
            @empty
                <p class="text-gray-500 text-center py-8 font-mono italic">No complaints found for the selected station or search term.</p>
            @endforelse
        </div>

        <div class="mt-6">
            {{ $complaints->links() }}
        </div>
    </div>
</x-app-layout>

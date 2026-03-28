<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-6">
        <!-- Header Section -->
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic">
                    Complaints <span class="text-blue-600">Database</span>
                </h1>
                <p class="text-sm text-slate-500 font-medium">Manage and review all incoming complaints from reception desks.</p>
            </div>
            
            <div class="flex items-center gap-3">
                @if($selectedStation)
                <a href="{{ route('complaints.download', ['police_station_id' => $selectedStation, 'search' => $searchTerm]) }}" 
                   class="inline-flex items-center px-4 py-2 bg-emerald-600 text-white text-sm font-bold rounded-lg hover:bg-emerald-700 transition-all shadow-lg shadow-emerald-600/20">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                    EXPORT CSV
                </a>
                @endif
            </div>
        </div>

        <!-- Filter Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                <form action="{{ route('complaints.index') }}" method="GET" class="grid grid-cols-1 md:grid-cols-12 gap-6">
                    <div class="md:col-span-5">
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2" for="policeStationSelect">
                            Police Station
                        </label>
                        @if(auth()->user()->hasRole('superior'))
                            <div class="relative">
                                <select disabled class="block w-full rounded-xl border-slate-200 bg-slate-100 text-slate-500 text-sm font-bold shadow-sm">
                                    <option>{{ auth()->user()->policeStation->name ?? 'Assigned Station' }}</option>
                                </select>
                                <input type="hidden" name="police_station_id" value="{{ auth()->user()->police_station_id }}">
                                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-slate-400">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path></svg>
                                </div>
                            </div>
                        @else
                            <select
                                id="policeStationSelect"
                                name="police_station_id"
                                onchange="this.form.submit()"
                                class="block w-full rounded-xl border-slate-200 text-slate-700 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all"
                            >
                                <option value="">-- All Stations --</option>
                                @foreach($policeStations as $station)
                                    <option value="{{ $station->id }}" {{ $selectedStation == $station->id ? 'selected' : '' }}>
                                        {{ $station->name }}
                                    </option>
                                @endforeach
                            </select>
                        @endif
                    </div>
                    
                    <div class="md:col-span-7">
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2" for="searchComplaints">
                            Quick Search
                        </label>
                        <div class="relative">
                            <input
                                type="text"
                                id="searchComplaints"
                                name="search"
                                value="{{ $searchTerm }}"
                                placeholder="Search by name, phone, address, or type..."
                                class="block w-full pl-10 rounded-xl border-slate-200 text-slate-700 text-sm font-medium shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all"
                            />
                            <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                <svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                            </div>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Table View (Modern List) -->
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50 text-slate-500">
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Complainant Info</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Category / Type</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Description</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-right">Registered On</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        @forelse($complaints as $complaint)
                            <tr class="hover:bg-slate-50/50 transition-colors group">
                                <td class="px-6 py-4">
                                    <div class="font-bold text-slate-900">{{ $complaint->complainant_name }}</div>
                                    <div class="text-xs text-blue-600 font-bold flex items-center mt-0.5">
                                        <a href="tel:{{ $complaint->phone }}" class="flex items-center hover:underline">
                                            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                                            </svg>
                                            {{ $complaint->phone }}
                                        </a>
                                    </div>
                                    <div class="text-[10px] text-slate-500 mt-1 uppercase font-bold tracking-tighter">{{ Str::limit($complaint->address, 30) }}</div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-black bg-blue-100 text-blue-700 uppercase tracking-tighter shadow-sm border border-blue-200">
                                        {{ $complaint->subCategory->name ?? 'N/A' }}
                                    </span>
                                    <div class="text-[10px] text-slate-400 mt-1 italic font-bold uppercase tracking-widest">
                                        {{ $complaint->policeStation->name ?? 'N/A' }}
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="text-xs text-slate-600 font-medium max-w-xs truncate">{{ $complaint->description }}</div>
                                    <div class="text-[10px] text-slate-400 mt-1 font-bold italic">Rec: {{ $complaint->receptionist->name ?? 'N/A' }}</div>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="text-xs font-bold text-slate-900">{{ $complaint->created_at->format('d M, Y') }}</div>
                                    <div class="text-[10px] font-bold text-slate-500">{{ $complaint->created_at->format('h:i A') }}</div>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <div class="flex items-center justify-center gap-2">
                                        <form action="{{ route('complaints.destroy', $complaint) }}" method="POST" class="inline">
                                            @csrf @method('DELETE')
                                            <button type="submit" onclick="return confirm('Archive/Delete this record?')" class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all group">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                </svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="px-6 py-12 text-center">
                                    <div class="flex flex-col items-center">
                                        <svg class="w-12 h-12 text-slate-200 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                        </svg>
                                        <p class="text-slate-500 text-sm font-bold uppercase tracking-widest">No matching records found</p>
                                    </div>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            @if($complaints->hasPages())
                <div class="p-6 border-t border-slate-100 bg-slate-50/30">
                    {{ $complaints->links() }}
                </div>
            @endif
        </div>
    </div>
</x-app-layout>

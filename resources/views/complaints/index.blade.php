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
                <a href="{{ route('complaints.download', ['police_station_id' => $selectedStation, 'sub_category_id' => $selectedSubCategory, 'start_date' => $startDate, 'end_date' => $endDate, 'search' => $searchTerm]) }}" 
                   class="inline-flex items-center px-4 py-2 bg-emerald-600 text-white text-sm font-bold rounded-lg hover:bg-emerald-700 transition-all shadow-lg shadow-emerald-600/20">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                    EXPORT CSV
                </a>
            </div>
        </div>

        <!-- Filter Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                <form action="{{ route('complaints.index') }}" method="GET" class="grid grid-cols-1 md:grid-cols-12 gap-6">
                    <div class="md:col-span-3">
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2" for="policeStationSelect">
                            Police Station
                        </label>
                        @if(auth()->user()->hasRole('superior'))
                            <div class="relative">
                                <select disabled class="block w-full rounded-xl border-slate-200 bg-slate-100 text-slate-500 text-sm font-bold shadow-sm">
                                    <option>{{ auth()->user()->policeStation->name ?? 'Assigned Station' }}</option>
                                </select>
                                <input type="hidden" name="police_station_id" value="{{ auth()->user()->police_station_id }}">
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

                    <div class="md:col-span-3">
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2" for="subCategorySelect">
                            Sub-Category
                        </label>
                        <select
                            id="subCategorySelect"
                            name="sub_category_id"
                            onchange="this.form.submit()"
                            class="block w-full rounded-xl border-slate-200 text-slate-700 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all"
                        >
                            <option value="">-- All Types --</option>
                            @foreach($subCategories as $subCat)
                                <option value="{{ $subCat->id }}" {{ $selectedSubCategory == $subCat->id ? 'selected' : '' }}>
                                    {{ $subCat->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <div class="md:col-span-3">
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">
                            Date From
                        </label>
                        <input
                            type="date"
                            name="start_date"
                            value="{{ $startDate }}"
                            onchange="this.form.submit()"
                            class="block w-full rounded-xl border-slate-200 text-slate-700 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all"
                        />
                    </div>

                    <div class="md:col-span-3">
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">
                            Date To
                        </label>
                        <input
                            type="date"
                            name="end_date"
                            value="{{ $endDate }}"
                            onchange="this.form.submit()"
                            class="block w-full rounded-xl border-slate-200 text-slate-700 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all"
                        />
                    </div>
                    
                    <div class="md:col-span-12">
                        <div class="relative">
                            <input
                                type="text"
                                name="search"
                                value="{{ $searchTerm }}"
                                placeholder="Search by name, phone, address, or description..."
                                class="block w-full pl-10 rounded-xl border-slate-200 text-slate-700 text-sm font-medium shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all"
                            />
                            <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                <svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                            </div>
                            <div class="absolute inset-y-0 right-0 flex items-center pr-3">
                                <button type="submit" class="text-xs font-black text-blue-600 hover:text-blue-700 uppercase tracking-widest">Apply Search</button>
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
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Subject & Details</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Action Taken</th>
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
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-black bg-blue-50 text-blue-600 uppercase tracking-tighter border border-blue-100 mb-1.5">
                                        {{ $complaint->subCategory->name ?? 'N/A' }}
                                    </span>
                                    <div class="text-xs text-slate-600 font-medium max-w-xs line-clamp-2 leading-relaxed">
                                        {{ $complaint->description }}
                                    </div>

                                    @if($complaint->note)
                                        <div class="mt-2 p-2 bg-amber-50 border border-amber-100 rounded-lg max-w-xs">
                                            <div class="text-[9px] font-black text-amber-800 uppercase tracking-widest mb-0.5 flex items-center">
                                                <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                                                Superior Note
                                            </div>
                                            <p class="text-[10px] text-amber-900 font-medium leading-tight italic line-clamp-2">"{{ $complaint->note }}"</p>
                                        </div>
                                    @endif

                                    <div class="text-[10px] text-slate-400 mt-1 font-bold italic">
                                        {{ $complaint->policeStation->name ?? 'N/A' }} • Rec: {{ $complaint->receptionist->name ?? 'N/A' }}
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    @php
                                        $isHighPriority = (strcasecmp(trim($complaint->subCategory->category->priority ?? ''), 'High Priority') === 0);
                                        $isOverdue = $complaint->created_at->diffInHours(now()) >= 24;
                                        $hasNoAction = empty($complaint->action_taken);
                                    @endphp

                                    @if($complaint->action_taken)
                                        <div class="font-black text-[11px] text-slate-800 uppercase tracking-wide flex items-center mb-1">
                                            <div class="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-2 shadow-[0_0_8px_rgba(16,185,129,0.5)]"></div>
                                            {{ $complaint->action_taken }}
                                        </div>
                                        <p class="text-[11px] text-slate-500 line-clamp-2 leading-snug">
                                            {{ $complaint->action_details }}
                                        </p>
                                    @elseif($isHighPriority && $isOverdue && $hasNoAction)
                                        <div class="inline-flex items-center px-2.5 py-1 rounded-lg bg-rose-50 border border-rose-200 shadow-sm animate-pulse">
                                            <div class="w-2 h-2 rounded-full bg-rose-600 mr-2"></div>
                                            <span class="text-[10px] font-black text-rose-700 uppercase tracking-tighter">Immediate Action Required</span>
                                        </div>
                                        <p class="text-[9px] text-rose-500 font-bold mt-1 uppercase tracking-widest leading-none">No action taken within 24 hours</p>
                                    @else
                                        <div class="flex items-center text-slate-400 italic">
                                            <svg class="w-3 h-3 mr-1.5 opacity-40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                                            <span class="text-[10px] font-bold uppercase tracking-widest">Pending Action</span>
                                        </div>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="text-xs font-bold text-slate-900">{{ $complaint->created_at->format('d M, Y') }}</div>
                                    <div class="text-[10px] font-bold text-slate-500">{{ $complaint->created_at->format('h:i A') }}</div>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <div class="flex items-center justify-center gap-1">
                                        <button onclick="openViewModal({{ json_encode($complaint) }})" class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-all" title="View Details">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                            </svg>
                                        </button>

                                        @if(auth()->user()->hasRole(['super', 'admin', 'superior']))
                                        <button onclick="openActionModal({{ $complaint->id }}, '{{ addslashes($complaint->action_taken) }}', '{{ addslashes($complaint->action_details) }}')" class="p-2 text-slate-400 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-all" title="Update Action">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                            </svg>
                                        </button>
                                        @endif

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

    <!-- View Modal -->
    <div id="viewModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center hidden">
        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden border border-slate-200">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Complaint Details</h3>
                <button onclick="closeViewModal()" class="text-slate-400 hover:text-slate-600 transition-colors">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            
            <div class="p-8 max-h-[80vh] overflow-y-auto custom-scrollbar space-y-8">
                <!-- Grid Info -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <div>
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1">Complainant Name</label>
                        <div id="view_name" class="text-base font-bold text-slate-900"></div>
                    </div>
                    <div>
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1">Phone Number</label>
                        <div id="view_phone" class="text-base font-bold text-blue-600"></div>
                    </div>
                    <div class="md:col-span-2">
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1">Address</label>
                        <div id="view_address" class="text-sm font-medium text-slate-700 leading-relaxed"></div>
                    </div>
                    <div>
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1">Category / Type</label>
                        <div id="view_category" class="inline-flex px-2 py-0.5 rounded bg-blue-50 text-blue-700 text-xs font-black uppercase"></div>
                    </div>
                    <div>
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1">Registered At</label>
                        <div id="view_date" class="text-sm font-bold text-slate-700"></div>
                    </div>
                </div>

                <!-- Description -->
                <div class="bg-slate-50 rounded-2xl p-6 border border-slate-100">
                    <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-3">Incident Description</label>
                    <p id="view_description" class="text-sm text-slate-700 leading-relaxed font-medium italic"></p>
                </div>

                <!-- Official Note (Restored) -->
                <div id="view_note_section" class="hidden">
                    <div class="bg-amber-50 rounded-2xl p-6 border border-amber-100">
                        <label class="text-[10px] font-black text-amber-600 uppercase tracking-widest block mb-3">Superior Instructions / Note</label>
                        <p id="view_note_text" class="text-sm text-amber-900 leading-relaxed font-medium italic"></p>
                    </div>
                </div>

                <!-- Action Taken -->
                <div id="view_action_section" class="hidden">
                    <div class="bg-emerald-50 rounded-2xl p-6 border border-emerald-100">
                        <label class="text-[10px] font-black text-emerald-600 uppercase tracking-widest block mb-3">Action Taken Detail</label>
                        <div id="view_action_name" class="text-sm font-black text-emerald-900 mb-2 uppercase italic"></div>
                        <p id="view_action_details" class="text-sm text-emerald-800 leading-relaxed font-medium"></p>
                    </div>
                </div>

                <!-- Logistics -->
                <div class="pt-4 border-t border-slate-100 grid grid-cols-2 gap-4">
                    <div>
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1">Police Station</label>
                        <div id="view_station" class="text-xs font-bold text-slate-600 uppercase"></div>
                    </div>
                    <div class="text-right">
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1">Receptionist</label>
                        <div id="view_receptionist" class="text-xs font-bold text-slate-600"></div>
                    </div>
                </div>
            </div>
            
            <div class="p-6 bg-slate-50 text-center">
                <button onclick="closeViewModal()" class="px-8 py-2.5 bg-slate-900 text-white text-xs font-black rounded-xl hover:bg-slate-800 transition-all uppercase tracking-widest">Close Record</button>
            </div>
        </div>
    </div>

    <!-- Action Modal -->
    <div id="actionModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center hidden">
        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden border border-slate-200">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Update Complaint Action</h3>
                <button onclick="closeActionModal()" class="text-slate-400 hover:text-slate-600 transition-colors">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            
            <form id="actionForm" method="POST" class="p-6 space-y-5">
                @csrf
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Choose Action</label>
                        <select id="input_action_taken" name="action_taken" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all">
                            <option value="">-- No Action Selected --</option>
                            @foreach($actionTakenList as $actionOption)
                                <option value="{{ $actionOption->name }}">{{ $actionOption->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Action Details</label>
                        <textarea id="input_action_details" name="action_details" rows="2" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="Briefly explain..."></textarea>
                    </div>
                </div>
                
                <div class="pt-4 flex gap-3">
                    <button type="button" onclick="closeActionModal()" class="flex-1 py-2.5 bg-slate-100 text-slate-600 text-xs font-black rounded-xl hover:bg-slate-200 transition-all uppercase tracking-widest">Cancel</button>
                    <button type="submit" class="flex-1 py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">Commit Action</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openActionModal(id, currentAction, currentDetails) {
            document.getElementById('input_action_taken').value = currentAction || '';
            document.getElementById('input_action_details').value = currentDetails || '';
            document.getElementById('actionForm').action = `/complaints/${id}/action`;
            document.getElementById('actionModal').classList.remove('hidden');
        }
        function closeActionModal() { document.getElementById('actionModal').classList.add('hidden'); }

        function openViewModal(complaint) {
            document.getElementById('view_name').innerText = complaint.complainant_name;
            document.getElementById('view_phone').innerText = complaint.phone;
            document.getElementById('view_address').innerText = complaint.address;
            document.getElementById('view_category').innerText = complaint.sub_category?.name || 'N/A';
            document.getElementById('view_description').innerText = complaint.description;
            document.getElementById('view_station').innerText = complaint.police_station?.name || 'N/A';
            document.getElementById('view_receptionist').innerText = complaint.receptionist?.name || 'N/A';
            
            const date = new Date(complaint.created_at);
            document.getElementById('view_date').innerText = date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true });

            if (complaint.note) {
                document.getElementById('view_note_section').classList.remove('hidden');
                document.getElementById('view_note_text').innerText = complaint.note;
            } else {
                document.getElementById('view_note_section').classList.add('hidden');
            }

            if (complaint.action_taken) {
                document.getElementById('view_action_section').classList.remove('hidden');
                document.getElementById('view_action_name').innerText = complaint.action_taken;
                document.getElementById('view_action_details').innerText = complaint.action_details || 'No additional details provided.';
            } else {
                document.getElementById('view_action_section').classList.add('hidden');
            }

            document.getElementById('viewModal').classList.remove('hidden');
        }
        function closeViewModal() { document.getElementById('viewModal').classList.add('hidden'); }
    </script>
</x-app-layout>

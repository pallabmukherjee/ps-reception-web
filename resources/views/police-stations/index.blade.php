<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-8">
        <!-- Header Section -->
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic">
                    Police <span class="text-blue-600">Stations</span>
                </h1>
                <p class="text-sm text-slate-500 font-medium">Configure and manage jurisdictional units within the district.</p>
            </div>
        </div>

        <!-- Create Station Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Register New Unit</h3>
            </div>
            
            <div class="p-6">
                <form action="{{ route('police-stations.store') }}" method="POST" class="flex flex-col md:flex-row gap-6">
                    @csrf
                    <div class="flex-1">
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="name">Station Name</label>
                        <input type="text" id="name" name="name" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="e.g. Kotwali PS" />
                    </div>
                    <div class="flex items-end">
                        <button type="submit" class="px-8 py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">
                            Authorize Station
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Table View -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50 text-slate-500">
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Station Identity</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Notification ID</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Authorized On</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        @forelse($policeStations as $station)
                            <tr class="hover:bg-slate-50/50 transition-colors">
                                <td class="px-6 py-4 font-bold text-slate-900">{{ $station->name }}</td>
                                <td class="px-6 py-4">
                                    <span class="font-mono text-xs bg-slate-100 px-2 py-1 rounded text-slate-600">{{ $station->notification_id ?? 'N/A' }}</span>
                                </td>
                                <td class="px-6 py-4 text-xs font-medium text-slate-500">{{ $station->created_at->format('d M, Y') }}</td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-center gap-2">
                                        <button onclick="openEditModal({{ $station->id }}, '{{ addslashes($station->name) }}')" class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-all">
                                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                            </svg>
                                        </button>
                                        <form action="{{ route('police-stations.destroy', $station) }}" method="POST" onsubmit="return confirm('Permanently remove this station?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                </svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="px-6 py-12 text-center text-slate-400 font-medium italic">No units registered yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Edit Modal -->
    <div id="editModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center hidden">
        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden border border-slate-200">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Update Station Name</h3>
            </div>
            <form id="editForm" method="POST" class="p-6">
                @csrf @method('PATCH')
                <div class="mb-6">
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">New Identity</label>
                    <input type="text" id="edit_name" name="name" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" />
                </div>
                <div class="flex gap-3">
                    <button type="button" onclick="closeEditModal()" class="flex-1 py-2.5 bg-slate-100 text-slate-600 text-xs font-black rounded-xl hover:bg-slate-200 transition-all uppercase tracking-widest">Cancel</button>
                    <button type="submit" class="flex-1 py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 transition-all uppercase tracking-widest">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(id, name) {
            document.getElementById('edit_name').value = name;
            document.getElementById('editForm').action = `/police-stations/${id}`;
            document.getElementById('editModal').classList.remove('hidden');
        }
        function closeEditModal() { document.getElementById('editModal').classList.add('hidden'); }
    </script>
</x-app-layout>
